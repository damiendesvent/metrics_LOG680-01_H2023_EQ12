import logging
from datetime import datetime
from urllib.error import HTTPError
import uuid

import schedule
import time
import threading
import sys
import os
import tempfile

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
    def __init__(self, github_token, db, project_id=3, project_owner='damiendesvent'):
        self.logging = logging

        schedule.every(0.5).minutes.do(self.background_job)

        # Start the background thread
        self.stop_run_continuously = self.run_continuously()
        
        self.github_client = GithubClient(github_token)
        
        # # self.github_client.get_user('elblogbruno')
        # # self.github_client.get_columns_for_project(3, 'damiendesvent')
        # self.github_client.get_columns_for_project(3, 'damiendesvent')
        self.db = db
        self.project_id = project_id
        self.project_owner = project_owner
        self.last_snapshot_json = None

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
        self.logging.info("Creating column {0} if not exists".format(column_name))
        
        column = columns_utils.get_column_by_name(self.db, column_name)
        
        if column is None:
            self.logging.info("Column {0} does not exist, creating it".format(column_name))

            column_schema = src.schemas.ProjectColumn(
                id=str(uuid.uuid4()),
                project_id=3,
                name=column_name,
                cards=[],
                created_at=datetime.now(),
            )

            column = columns_utils.create_new_column(self.db, column_schema)
        else:
            self.logging.info("Column {0} already exists".format(column_name))

        return column

    def create_card_if_not_exists(self, card_json, column):
        self.logging.info("Creating card if not exists")
        self.logging.info(card_json)

        card = cards_utils.get_card_by_content(self.db, card_json['bodyText'])

        if card is None: # if the card does not exist we create it and add it to the column
            self.logging.info("Card does not exist, creating it")
            
            card_schema = Card(
                id=str(uuid.uuid4()),
                project_id=self.project_id,
                column_id = column.id,
                name = card_json['title'],
                content= card_json['bodyText'],
                created_at= card_json['createdAt'],
            )

            card = column.add_card(card_schema, self.db)
        else:
            self.logging.info("Card already exists") 

            # create a new card with the same content, but in the new column . We cant have two cards with the same id on the database
            # so we create a new Id that can relate to the old id

            new_id = card.id + "_new_" + str(uuid.uuid4())[0:5] # we add a random string to the id to make it unique, but still related to the old id .
            # we do this because we want to keep the old card in the old column, but we want to add the card to the new column as well
            # the first uuid is the old id from original card, the second is the new id

            card_schema = Card(
                id=new_id,
                project_id=self.project_id,
                column_id = column.id,
                name = card_json['title'],
                content=card_json['bodyText'], # if the content changes we are able to store it updated on the snapshot
                created_at=card_json['createdAt'],
            )

            card = column.add_card(card_schema, self.db)

        return card

    
    def snapshot(self):
        self.logging.info("Snapshotting...")

        result = self.github_client.get_columns_for_project(self.project_id, self.project_owner) # we contact github to get the latest cards and columns
        nodes = result['user']['projectV2']['items']['nodes']

        for node in nodes:
            self.logging.info(node) # we log the node to see what we are getting from github

            card_json = node['content'] # we get the card json
            card_created_at = card_json['createdAt'] # we get the card created at date

            status = node['status'] # we get the status of the card, which contains the column name
            self.logging.info(status) # we log the status to see what we are getting from github

            column_name = status['column'] # we get the column name from the status
            column_schema = self.create_column_if_not_exists(column_name) # we create the column if it does not exist on the database

            # calculate the difference between now and the last snapshot, checking which card has been moved
            # if the card has been moved, we add it to the new column with a new id (we cant have two cards with the same id on the database)

            if self.last_snapshot_json is not None:
                last_snapshot_nodes = self.last_snapshot_json['user']['projectV2']['items']['nodes']
               
                for last_snapshot_node in last_snapshot_nodes:
                    last_snapshot_card_json = last_snapshot_node['content']
                    last_snapshot_card_created_at = last_snapshot_card_json['createdAt']
            
                    if last_snapshot_card_created_at == card_created_at:
                        # the card has been moved
                        last_snapshot_status = last_snapshot_node['status']
                        last_snapshot_column_name = last_snapshot_status['column']

                        if last_snapshot_column_name != column_name:
                            # the card has been moved to a different column
                            self.logging.info("Card {0} has been moved from {1} to {2}".format(card_json['title'], last_snapshot_column_name, column_name))

                            # we create the card in the new column with a new id that is related to the old id
                            created_card = self.create_card_if_not_exists(card_json, column_schema)

            else:

                created_card = self.create_card_if_not_exists(card_json, column_schema)

        self.last_snapshot_json = result



    def background_job(self):
        print("Snapshotting...")
        self.snapshot()
