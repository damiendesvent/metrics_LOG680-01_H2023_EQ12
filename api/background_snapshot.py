import json
import logging
from datetime import datetime
from urllib.error import HTTPError
import uuid

import schedule
import time
import threading
import os

from github import GithubClient
import src.schemas

from src.models.models import Card

import src.utils.cards as cards_utils
import src.utils.columns as columns_utils

dir_path = 'background_worker.log'

logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# # define a Handler which writes INFO messages or higher to the sys.stderr
# console = logging.StreamHandler()
# console.setLevel(logging.INFO)
# # add the handler to the root logger
# logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

class Worker:
    def __init__(self, github_token,  db, finished_column_name="done", snapshot_interval=0.2, project_id=3, project_owner='damiendesvent'):
        # logging = logging

        schedule.every(snapshot_interval).minutes.do(self.background_job)

        # Start the background thread
        self.stop_run_continuously = self.run_continuously()
        
        self.github_client = GithubClient(github_token)
        
        # # self.github_client.get_user('elblogbruno')
        # # self.github_client.get_columns_for_project(3, 'damiendesvent')
        # self.github_client.get_columns_for_project(3, 'damiendesvent')
        self.db = db
        self.project_id = project_id
        self.project_owner = project_owner
        self.finished_column_name = finished_column_name

        self.last_snapshot_json = self.__get_last_snapshot()

    def __get_last_snapshot(self):
        if os.path.isfile('last_snapshot.json'):
            print("last_snapshot.json exists")
            with open('last_snapshot.json', 'r') as f:
                return json.load(f)
        else:
            print("last_snapshot.json does not exist")
            return None

    def run_continuously(self, interval=1):
        """Continuously run, while executing pending jobs at each
        elapsed time interval.
        @return cease_continuous_run: threading. Event which can
        be set to cease continuous run. Please note that it is
        *intended behavior that run_continuously() does not run
        missed jobs*. For example, if you've registered a job that
        should run every minute and you set a continuous run
        interval of one hour then your job won't be run 60 times
        at each interval but only once.
        """
        cease_continuous_run = threading.Event()

        class ScheduleThread(threading.Thread):
            @classmethod
            def run(cls):
                while not cease_continuous_run.is_set():
                    schedule.run_pending()
                    time.sleep(interval)

        continuous_thread = ScheduleThread()
        continuous_thread.start()
        return cease_continuous_run

    def create_column_if_not_exists(self, column_name):
        logging.info("Creating column {0} if not exists".format(column_name))
        
        column = columns_utils.get_column_by_name(self.db, column_name)
        
        if column is None:
            logging.info("Column {0} does not exist, creating it".format(column_name))

            column_schema = src.schemas.ProjectColumn(
                id=str(uuid.uuid4()),
                project_id=3,
                name=column_name,
                cards=[],
                created_at=datetime.now(),
            )

            column = columns_utils.create_new_column(self.db, column_schema)
        else:
            logging.info("Column {0} already exists".format(column_name))

        return column

    def create_card_if_not_exists(self, card_json, column):
        logging.info("Creating card if not exists")
        logging.info(card_json['title'])

        card = cards_utils.get_card_by_content_and_created_at(self.db, card_json['bodyText'], card_json['createdAt'])

        if card is None: # if the card does not exist we create it and add it to the column
            logging.info("Card does not exist, creating it")
            
            card_schema = Card(
                id=str(uuid.uuid4()),
                parent_card_id=None,
                project_id=self.project_id,
                column_id = column.id,
                name = card_json['title'],
                content= card_json['bodyText'],
                created_at= card_json['createdAt'],
                uploaded_at = datetime.now(),
                finished_at = None,
                lead_time = None,
            )

            card = column.add_card(card_schema, self.db)
        else:
            logging.info("Card already exists") 

            # create a new card with the same content, but in the new column . We cant have two cards with the same id on the database
            # so we create a new Id that can relate to the old id

            # new_id = str(card.id) + "_new_" + str(uuid.uuid4())[0:5] # we add a random string to the id to make it unique, but still related to the old id .
            # we do this because we want to keep the old card in the old column, but we want to add the card to the new column as well
            # the first uuid is the old id from original card, the second is the new id

            # make a new id getting first 5 characters of the old id and adding a uuid
            # new_id = str(card.id)[0:5] + str(uuid.uuid4())[0:5]

            

            card_schema = Card(
                id=str(uuid.uuid4()),
                parent_card_id=card.id,
                project_id=self.project_id,
                column_id = column.id,
                name = card_json['title'],
                content=card_json['bodyText'], # if the content changes we are able to store it updated on the snapshot
                created_at=card_json['createdAt'],
                uploaded_at = datetime.now(),
            )

            # update the old card with the new column id
            card.column_id = column.id
            card.content = card_json['bodyText'] # if the content changes we are able to store it updated on the snapshot
            

            if column.name == self.finished_column_name:
                logging.info("Card is in the finished column, calculating lead time")
                # calculate the time it took to finish the card
                card.finished_at = datetime.now()
                lead_time = card.finished_at - card.created_at
                card.lead_time = lead_time.total_seconds()

                # q: why lead_time.total_seconds() and not lead_time.seconds?
                # a: because lead_time.seconds only returns the seconds of the time, not the days, hours, minutes, etc
                # so if the card took 2 days to finish, lead_time.seconds would return 0, but lead_time.total_seconds() would return 172800
                # q: why it is negative?
                # a: because the finished_at is the time the card was moved to the finished column, and the created_at is the time the card was created
                # so if the card was created at 10:00 and finished at 12:00, the lead time would be 2 hours, but the finished_at would be 12:00 and the created_at would be 10:00
                # so the lead time would be 12:00 - 10:00 = 2 hours, but the lead time is 2 hours, not -2 hours, so we need to make it positive

                # make the lead time positive
                if card.lead_time < 0:
                    card.lead_time = card.lead_time * -1


                logging.info("Lead time: {0} for card {1}".format(card.lead_time, card.id))

            card.save(self.db) # we save the card to the database to update the column id

            card = column.add_card(card_schema, self.db)

        return card

    
    def snapshot(self):
        logging.info("Snapshotting...")

        result = self.github_client.get_columns_for_project(self.project_id, self.project_owner) # we contact github to get the latest cards and columns
        nodes = result['user']['projectV2']['items']['nodes']

        for node in nodes:
            logging.info(node) # we log the node to see what we are getting from github

            card_json = node['content'] # we get the card json
            
            if len(card_json) == 0 or card_json is None: # if the card is empty we skip it
                logging.info("Card is empty, maybe we snapshoted before the card was created")
                continue

            card_created_at = card_json['createdAt'] # we get the card created at date

            status = node['status'] # we get the status of the card, which contains the column name
            # logging.info(status) # we log the status to see what we are getting from github

            column_name = status['column'] # we get the column name from the status
            column_schema = self.create_column_if_not_exists(column_name) # we create the column if it does not exist on the database

            # calculate the difference between now and the last snapshot, checking which card has been moved
            # if the card has been moved, we add it to the new column with a new id (we cant have two cards with the same id on the database)

            if self.last_snapshot_json is not None:
                last_snapshot_nodes = self.last_snapshot_json['user']['projectV2']['items']['nodes']
               
                for last_snapshot_node in last_snapshot_nodes:
                    last_snapshot_card_json = last_snapshot_node['content']

                    if len(last_snapshot_card_json) == 0 or last_snapshot_card_json is None: # if the card is empty we skip it
                        logging.info("Card is empty, maybe we snapshoted before the card was created")
                        continue

                    last_snapshot_card_created_at = last_snapshot_card_json['createdAt']
            
                    if last_snapshot_card_created_at == card_created_at: # if the card was created at the same time, we check if the card has been moved to a different column

                        # the card has been moved
                        last_snapshot_status = last_snapshot_node['status']
                        last_snapshot_column_name = last_snapshot_status['column']

                        if last_snapshot_column_name != column_name: 
                            # the card has been moved to a different column
                            logging.info("Card {0} has been moved from {1} to {2}".format(card_json['title'], last_snapshot_column_name, column_name))

                            # we create the card in the new column with a new id that is related to the old id
                            created_card = self.create_card_if_not_exists(card_json, column_schema)


                # if we have a new card that was not in the last snapshot, we create it
                if last_snapshot_card_created_at != card_created_at:
                    logging.info("New card {0} in column {1}".format(card_json['title'], column_name))
                    created_card = self.create_card_if_not_exists(card_json, column_schema)

            else:
                logging.info("No last snapshot, creating card {0} in column {1}".format(card_json['title'], column_name))
                created_card = self.create_card_if_not_exists(card_json, column_schema)

        self.last_snapshot_json = result

        # we save the snapshot to a json file
        with open('last_snapshot.json', 'w') as outfile:
            json.dump(result, outfile)
            


    def background_job(self):
        self.snapshot()
