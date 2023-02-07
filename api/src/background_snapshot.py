import json
import logging
from datetime import datetime
from urllib.error import HTTPError
import uuid

import schedule
import time
import threading
import os

from src.github import GithubClient
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
    def __init__(self, github_token,  db, snapshot_interval=0.2, project_id=3, project_owner='damiendesvent'):
        # logging = logging
        print("Initializing worker with snapshot interval: {0}".format(snapshot_interval))

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

        self.last_snapshot_json = self.__get_last_snapshot()

        # make a singleton out of this class
        Worker.__instance = self

    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, 'instance'):
            cls.__instance = super(Worker, cls).__new__(cls)
        return cls.__instance

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


    """
        Creates a new column if it does not exist, otherwise it returns the existing one
    """
    def create_column_if_not_exists(self, column_name):
        logging.info("Creating column {0} if not exists".format(column_name))
        
        column = columns_utils.get_column_by_name(self.db, column_name, self.project_owner, self.project_id)
        
        if column is None:
            logging.info("Column {0} does not exist, creating it".format(column_name))

            column_schema = src.schemas.ProjectColumn(
                id=str(uuid.uuid4()),
                project_id=self.project_id,
                project_owner=self.project_owner,
                name=column_name,
                cards=[],
                created_at=datetime.now(),
            )

            column = columns_utils.create_new_column(self.db, column_schema)
        else:
            logging.info("Column {0} already exists".format(column_name))

        return column

    """
        Creates a new card if it does not exist, otherwise it returns the existing one
    """
    def create_card_if_not_exists(self, card_json, column):
        logging.info("Creating card if not exists")
        logging.info(card_json['title'])

        card = cards_utils.get_card_by_content_and_created_at(self.db, card_json['bodyText'], card_json['createdAt'])

        labels = card_json['labels']['nodes']
        if labels:
            labels = [label['name'] for label in labels]
        else:
            labels = []

        assignees = card_json['assignees']['nodes']
        if assignees:
            assignees = [assignee['login'] for assignee in assignees]
        else:
            assignees = []

        title = card_json['title'] # this is to avoid encoding issues when saving to the db
        content = card_json['bodyText'] # this is to avoid encoding issues when saving to the db
        
        uploaded_at = datetime.now()
        created_at = card_json['createdAt']

        state = card_json['state'] if 'state' in card_json else None
        pull_state = card_json['pullState'] if 'pullState' in card_json else None

        creator = card_json['author']['login'] if 'author' in card_json else None

        if card is None: # if the card does not exist we create it and add it to the column
            logging.info("Card does not exist, creating it")
            
            card_schema = Card(
                id=str(uuid.uuid4()),
                parent_card_id=None,
                project_id=self.project_id,
                project_owner=self.project_owner,
                column_id = column.id,
                name = title,
                content= content,
                created_at= created_at,
                uploaded_at = uploaded_at,
                closed_at = card_json['closedAt'] if card_json['closedAt'] else None,
                closed = card_json['closed'],
                lead_time = None,
                labels = str(labels),
                assignees = str(assignees),
                state = state,
                pull_state = pull_state,
                type_name = card_json['__typename'], # this is to know if the card is a pull request or an issue
                creator = creator,
            )

            self.check_card_closed(card_json, card_schema) # if the card is closed we calculate the lead time

            card = column.add_card(card_schema, self.db)
        else:
            logging.info("Card already exists") 
        
            card_schema = Card(
                id=str(uuid.uuid4()),
                parent_card_id=card.id,
                project_id=self.project_id,
                project_owner=self.project_owner,
                column_id = column.id,
                name = title,
                content= content, # if the content changes we are able to store it updated on the snapshot
                created_at= created_at,
                uploaded_at = uploaded_at,
                closed_at = None,
                closed = False,
                lead_time = None,
                labels = str(labels),
                assignees = str(assignees),
                state = state,
                pull_state = pull_state,
                type_name = card.type_name,
                creator = creator,
            )

            # update the old card with the new column id
            card.column_id = column.id
            card.content = content # if the content changes we are able to store it updated on the snapshot
            card.closed = card_json['closed'] # if the card is closed we update the closed field
            card.closed_at = card_json['closedAt'] # if the card is closed we update the closed at field
            card.labels = str(labels) # if the card has labels we update the labels field
            card.assignees = str(assignees) # if the card has assignees we update the assignees field
            card.state = state # if the card has state we update the state field
            card.pull_state = pull_state, # if the card has pull state we update the pull state field
            

            self.check_card_closed(card_json, card) # if the card is closed we calculate the lead time

            card.save(self.db) # we save the card to the database to update the column id

            card = column.add_card(card_schema, self.db)

        return card

    def check_card_closed(self, card_json, card):
        if card.closed == True: # if the card is in the finished column and is closed we calculate the lead time
            logging.info("Card is in the finished column and Closed is TRUE , calculating lead time")
            # calculate the time it took to finish the card
            # card.finished_at = datetime.now()
            
            if type(card_json['closedAt']) is str:
                card.closed_at = datetime.strptime(card_json['closedAt'], '%Y-%m-%dT%H:%M:%SZ')

            if type(card_json['createdAt']) is str:
                card.created_at = datetime.strptime(card_json['createdAt'], '%Y-%m-%dT%H:%M:%SZ')
            

            lead_time = card.closed_at - card.created_at
            card.lead_time = lead_time.total_seconds()

            # make the lead time positive
            if card.lead_time < 0:
                card.lead_time = card.lead_time * -1


            logging.info("Lead time: {0} for card {1}".format(card.lead_time, card.id))
        else:
            logging.info("Card is not closed, not calculating lead time")

    def set_project_info(self, project_id, project_owner):
        self.set_project_id(project_id)
        self.set_project_owner(project_owner)

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

                current_card_found = False # we use this to check if the card was found on the last snapshot

               
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
                            current_card_found = True 
                            break


                # if we have a new card that was not in the last snapshot, we create it
                if not current_card_found and cards_utils.get_card_by_content_and_created_at(self.db, card_json['bodyText'], card_created_at) is None:
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
