from flask import render_template
from flask import Flask, jsonify, request, make_response, url_for
import psycopg2
import praw
from elasticsearch import Elasticsearch
from .config import (user,
password,
host,
port,
database,
client_id,
client_secret,
user_agent)


# Flask App
app = Flask(__name__, static_url_path='/Users/dm/Desktop/insight_html/static')

# ELASTIC SEARCH Client
es = Elasticsearch([{'host': '54.212.124.15', 'port': 9200}])

# REDDIT CLIENT
reddit = praw.Reddit(client_id=client_id, client_secret=client_secret,
                        user_agent=user_agent)

# default list of 15 recent posts from Reddit -
reddit_posts = [submission.title for submission in reddit.subreddit('all').hot(limit=30)]

subreddit_state={
    "subreddit_name":"Reddit",
    "year":2019,
    "month":None,
    "tags":None
}

def handle_postges(subreddit_name ,year, month):
    """
    Fetch data from Postgres
    :param text_field:
    :param year_field:
    :param month_field:
    :return:
    """
    try:
        # set connection
        connection = psycopg2.connect(user=user,
                                      password=password,
                                      host=host,
                                      port=port,
                                      database=database)
        # set cursor
        cursor = connection.cursor()
        # query
        postgreSQL_select_Query = "select word from word_count where subreddit=%s and year=%s and month=%s"

        input=(subreddit_name, year, month)
        cursor.execute(postgreSQL_select_Query,input)

        # execute query
        word_list = cursor.fetchmany(10)
        result_list=[word[0] for word in word_list]

        # close connection
        connection.commit()

    finally:
        # closing database connection.
        if (connection):
            cursor.close()
            connection.close()
            print("PostgreSQL connection is closed")

    return result_list


def handle_elasticsearch(subreddit_name, input_year, input_month, topic):
    res = es.search(index="comments_{0}_{1:02d}".format(input_year, input_month),
                    body={"from": 0,
                          "size": 10,
                          "query":
                              {
                              "bool":
                                  {
                                      "should": [{"match": {"subreddit": subreddit_name}},
                                              {"match":{"year": input_year}},
                                              {"match":{"month": input_month}},
                                              {"match": {"body": topic}}]
                                   }
                          }
                          }
                    )

    No_of_hits = res['hits']['total']['value']
    results_links = list()
    for hit in res['hits']['hits']:
        results_links.append(hit['_source']["body"])

    return results_links


# -----------------
# Error Handling
# -----------------
@app.errorhandler(400)
def not_found(error):
    return make_response(jsonify({'error': 'Bad Request'}), 400)


@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'No Such Data Found}'}), 404)


@app.errorhandler(408)
def not_found(error):
    return make_response(jsonify({'error': 'Request Timeout'}), 408)


@app.errorhandler(412)
def not_found(error):
    return make_response(jsonify({'error': 'Please select values from all the drop downs'}), 412)


# -----------------------
# Stage 2: Get Posts
# -----------------------
@app.route('/redditinsight/get_posts', methods=['POST'])
def get_filtered_posts():
    """
    Generate list of Posts from Elastic Search
    Input: Year, Month, Subreddit Name, Topic Name
    :return:
    """
    if request.method == 'POST':
        topic=request.form['topic']
        # get results from Elastic
        filtered_posts=handle_elasticsearch(subreddit_state["subreddit_name"][0], subreddit_state["year"][0],
                                            subreddit_state["month"], topic)

        return render_template("index.html",
                               subreddit_name= subreddit_state["subreddit_name"][0],
                               results=subreddit_state["tags"],
                               results_links=filtered_posts)
    else:
        return 404


# -----------------------
# Stage 1: Get Tags
# -----------------------
@app.route('/redditinsight/get_tags', methods=['POST'])
def process():
    if request.method == 'POST':
        print(request.form['taskoption1'])
        # get user inputs
        subreddit_name = request.form['taskoption1'].strip().lower()
        inp_year = request.form['taskoption2'].strip()
        inp_month = request.form['taskoption3'].strip()

        # initialize the submission
        subreddit_state["subreddit_name"]= subreddit_name,
        subreddit_state["year"]= int(inp_year),
        subreddit_state["month"]= int(inp_month)
        # defaults
        reddit_posts = []
        word_list=[]
        try:
            # fetch data from database
            word_list = handle_postges(subreddit_name,inp_year,inp_month)
            if len(word_list) == 0:
                word_list.append("There_are_no_tags_in_this_Subreddit")

            subreddit_state["tags"] = word_list
            for submission in reddit.subreddit(subreddit_name).top(limit=10):
                reddit_posts.append(submission.title)
            return render_template("index.html", subreddit_name= subreddit_state["subreddit_name"][0], results=word_list, results_links=reddit_posts)
        except:
            return 412


# ---- Home -----
# ----------------
@app.route('/')
def index():
    print("loaded template")
    return render_template("index.html", results_links=reddit_posts)


if __name__ == "__main__":
    app.run(port="80", host="0.0.0.0", debug=True)