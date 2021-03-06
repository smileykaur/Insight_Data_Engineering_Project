# #tagReddit

## `Motivation:`

Reddit is a community-driven social platform with lots of interesting posts shared every day across a number of 
subreddits on a variety of topics. This is great for Reddit community but this also leads to some problems for the users. The users have to spend a significant amount of time going over all the posts in order to discover interesting posts of their choice/preference in a subreddit they follow. While exploring a new Subreddit, users would want to spend less time to get an overview of the subreddit community they are exploring. In this project I come up with - **`Reddit-Tags`**, that would help to enhance `user experience` and improve `user engagement` by showing popular tags. The inspiration for **`Reddit-Tags`** come from hashtags used in other social media platforms like Instagram and Twitter. Hashtags allow users to explore new contents corresponding to each tags thereby increasing user engagement and improving user experience on the platform.

In addition to improving the user experience, the tags can also be helpful for `Ads team` to show ads based on the keywords clicked by users. 

### `Objective:` 
1. Generate popular tags(keywords) for each SubReddit for each month and year.
2. Index all the posts corresponding to each generated tag.
3. Allow user to see popular tags for a subreddit over the time. 


### ` Future Ideas:`
4. Identify the most active SubReddits (Real Time Processing)
5. Index posts in real time
6. Top keywords being used in last one hour


### ` Business Case:` 
1. Improve Customer Experience by generating tags for each subreddit and displaying corresponding list of posts
2. Displaying ads on relevant reddit channel
3. Seasonality insight can be used by Analyst and Marketing team in managing their social media/Ad campaigns

### `Dataset:` 
1. Data taken from Pushshift.io.

2. Size: 500 GB (taken from 2008 - 2015 for comments)
Schema - <img>
3. Data Stored in AWS S3 data lake in three separate buckets - 
> `Raw Comments`: Data taken from source, `Cleaned Comments`: Data generated after initial preprocessing, `Frequent Words`: Tags identified from the posts

### `Data Pipeline`
<img src="./img/pipeline.png" width="800">

**1. AWS S3:** Serve as datalake

<img src="./img/S3.png" width="400">

**2. Spark:** 4 node cluster, 1 master-3workers. I have written two separate pipelines on Spark, One to clean the text data, second to generate frequent tags from the cleaned data. 

<img src="./img/spark-transformation.png" width="600">

**3. Elasticsearch:** Indexed comments data on Elasticsearch. Used Spark to transform data into NDJSON format and then loaded on ES using bulk upload API. Comments were indexed by year. Latency to query indexes vary from .15 second to 1.35 seconds with variation in index size. 

**4. Airflow:** My cluster has used 

<img src="./img/airflow.png" width="600">

**5. Postgres:**

<img src="./img/postgres.png" width="400">

### `Cluster Setup`
The cluster was set up on AWS. All the services used in this project were set up by myself. I didn't use any `managed services` as they are very expensive and difficult to debug if you run into any errors. I used about 9 `m4.large` EC2 instances for the cluster.

### ``Engineering Challenge:``  
1. Text data preprocessing and cleaning which include - removing stopword, removing punctuations, removing urls etc. 
    Complexity:  O(M*(N^2))
    O(N^2) to compare two text bodies (comments vs stopwords)
    O(M) for all posts from reddit
    M= documents
    N= number of records 
2.  Spark performance improvement by increasing executor.memory from 1g to 6g, resulted in 5% increase in performance.
3.  Implement incremental aggregations and avoid re-computation.


### `` Presentation Slides:`` 
http://bit.ly/hashtag-reddit-slides

### `` Project Link:`` 
http://redditinsight.club/

### `` Project Demo:`` 
http://bit.ly/hashtag-reddit-demo



