from CB import *
from flask import Flask, jsonify, json, request
import time
import numpy as np
import pymongo
import csv
from CBHigher import *

start_time = time.time()
app = Flask(__name__)

myclient = pymongo.MongoClient("mongodb://localhost:27017/")
mydb = myclient["doantotnghiep"]
mycol = mydb["products"]
myCustomers = mydb["customers"]
myRatings = mydb["ratings"]


r_cols = ['user_id', 'product_id', 'rating']
# rating user
csvHeader = ["product_id", "title"]
itemCategoryList = {"Others": 0, "Hot": 1, "Cold": 2, "Spicy": 3, "Butter": 4, "Sweet": 5, "Salty": 6, "Greasy": 7, "Bland": 8, "Sour": 9}
data = []
with open('./products.csv', 'w', encoding='UTF8') as f:
    f.truncate()
    for x in mycol.find():
        categoryList = [0] * len(itemCategoryList)
        for categoryTitle in x["categories"]:
            if categoryTitle in itemCategoryList:
                categoryList[itemCategoryList[categoryTitle]] = 1
        categories = "|".join(str(category) for category in categoryList)
        row = str(x["_id"])+"|"+str(x["title"])+"|"+categories + "\n"
        f.write(row)
    f.close()
with open("./users.csv", 'w', encoding='UTF8') as f:
    f.truncate()
    pre_rating = pd.read_csv('./ratings.csv', sep='\t', names=r_cols, encoding='latin-1')
    print()
    for x in myCustomers.find():
        if pre_rating["user_id"].eq(int(str(x["_id"]))).any():
            f.write(str(x["_id"]) + "|" + str(x["username"]) + "\n")
    f.close()
with open("./ratings.csv", 'w', encoding='UTF8') as f:
    f.truncate()
    for x in myRatings.find():
        f.write(str(x["user_id"]) + "\t" + str(x["product_id"]) + "\t" + str(x["score"]) + "\n")
    f.close()

# non-rating user
csvHeader = ["productid", "title", "genres"]
data = []
with open('./nonproducts.csv', 'w', encoding='UTF8') as f:
    f.truncate()
    f.write(csvHeader[0]+","+csvHeader[1]+","+csvHeader[2])
    for x in mycol.find():
        categories = "|".join(x["categories"])
        row = "\n"+str(x["_id"])+","+str(x["title"])+","+categories
        f.write(row)
    f.close()

u_cols =  ['user_id', 'username']
# user information
users = pd.read_csv('./users.csv', sep='|', names=u_cols,
 encoding='latin-1')
n_users = users.shape[0]

# user rating product
ratings_base = pd.read_csv('./ratings.csv', sep='\t', names=r_cols, encoding='latin-1')
# ratings_test = pd.read_csv('ml-100k/ua.test', sep='\t', names=r_cols, encoding='latin-1')

rate_train = ratings_base.values
# rate_test = ratings_test.values

i_cols = ["product_id", "title", "Others", "Hot", "Cold", "Spicy", "Butter", "Sweet", "Salty", "Greasy", "Bland", "Sour"]

items = pd.read_csv('./products.csv', sep='|', names=i_cols, encoding='latin-1')
n_items = items.shape[0]


X0 = items.values
X_train_counts = X0[:, -10:]

cb = Contentbased(rate_train, X_train_counts, n_users= n_users, n_items = n_items, lamda=7)
cb.fit()

cbEntity = CB("./nonproducts.csv")
cbEntity.fit()

print('--- %s seconds ---' % (time.time() - start_time))

@app.route("/", methods=["GET"])
def index():
    textQuery = request.args.get('q')
    print(textQuery)
    predict = cb.recommend(int(textQuery), 3)
    print(predict)
    response = np.array(predict).tolist()
    return json.dumps({"response": response})

@app.route("/nonrating", methods=["GET"])
def nonrating():
    textQuery = request.args.get('q')
    print(textQuery)
    predict = cbEntity.genre_recommendations(textQuery, 3)
    print(predict[1])
    response = np.array(predict[1]).tolist()
    return json.dumps({"response": response})


app.run(port=5500)