import json
from gql import gql, Client
from gql.transport.aiohttp import AIOHTTPTransport


class GithubClient:

    def __init__(self, github_token):
        # transport = AIOHTTPTransport(url='YOUR_URL', headers={'Authorization': 'token'})

        self.transport = AIOHTTPTransport(url="https://api.github.com/graphql", headers={'Authorization': f"bearer {github_token}"}) 
        self.client = Client(transport=self.transport, fetch_schema_from_transport=True)
        # self.client.inject_token(f"bearer {github_token}")

    def get_user(self, username):
        query = gql(
            """
            query getUser($username: String!) {
              user(login: $username) {
                name
                avatarUrl
                bio
                email
                location
                login
                url
                websiteUrl
                twitterUsername
                followers {
                  totalCount
                }
                following {
                  totalCount
                }
                repositories {
                  totalCount
                }
                starredRepositories {
                  totalCount
                }
                gists {
                  totalCount
                }
                organizations {
                  totalCount
                }
                contributionsCollection {
                  contributionCalendar {
                    totalContributions
                  }
                }
              }
            }
            """
        )
        # Execute the query on the transport
        result = self.client.execute(query, variable_values={"username": username})
        return result

    def get_columns_for_project(self, project_id, username="damiendesvent", debug=False):
        query = gql(
            """
            query getUser($login: String!, $number: Int!) {
                user(login: $login) {
                    projectV2(number: $number) {
                        title
                        items(first: 100) {
                            pageInfo {
                                endCursor
                                hasNextPage
                            }
                            nodes {
                                content {
                                    ... on Issue {
                                        id
                                        title
                                        bodyText
                                        url
                                        state
                                        createdAt
                                        author {
                                            login
                                        }
                                        closed
                                        closedAt
                                        labels(first: 10) {
                                          nodes{
                                            name
                                          }
                                        }
                                    }
                                    ... on PullRequest {
                                        id
                                        title
                                        bodyText
                                        url
                                        createdAt
                                        author {
                                            login
                                        }
                                        closed
                                        closedAt
                                        labels(first: 10) {
                                          nodes{
                                            name
                                          }
                                        }
                                    }
                                }
                                status: fieldValueByName(name: "Status") {
                                    ... on ProjectV2ItemFieldSingleSelectValue {
                                    column: name
                                    updatedAt
                                    }
                                }
                            }
                        }
                    }
                }
            }
            """
        )

        # Execute the query on the transport
        result = self.client.execute(query, variable_values={"login": username, "number": project_id})

        # print json beautified
        if debug:
          print(json.dumps(result, indent=4, sort_keys=True))


        return result