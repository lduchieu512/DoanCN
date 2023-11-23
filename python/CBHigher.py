import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.linear_model import Ridge
from sklearn import linear_model

def get_items_rated_by_user(rate_matrix, user_id):
    y = rate_matrix[:,0]
    ids = np.where(y == user_id +1)[0]
    item_ids = rate_matrix[ids, 1] - 1
    scores = rate_matrix[ids, 2]
    return (item_ids, scores)

class Contentbased:
    def __init__(self, Y, X_train, n_users, n_items, lamda = 1):
        self.Y = Y
        self.lamda = lamda
        self.X_train = X_train
        self.n_users = n_users
        self.n_items = n_items
        self.hold = Y[:, 0]
        
    def fit(self):
        transformer = TfidfTransformer(smooth_idf=True, norm ='l2')
        tfidf = transformer.fit_transform(self.X_train.tolist()).toarray()
        d = tfidf.shape[1] # data dimension
        W = np.zeros((d, self.n_users))
        b = np.zeros((1, self.n_users))
        for n in range(self.n_users):    
            ids, scores = get_items_rated_by_user(self.Y, n)
            clf = Ridge(alpha= self.lamda, fit_intercept  = True)
            Xhat = tfidf[ids, :]
            clf.fit(Xhat, scores) 
            W[:, n] = clf.coef_
            b[0, n] = clf.intercept_
        self.Yhat = tfidf.dot(W) + b
        
    def RMSE(self, Data_test):
        se = 0
        cnt = 0
        for n in range(self.n_users):
            ids, scores_truth = get_items_rated_by_user(Data_test, n)
            scores_pred = self.Yhat[ids, n]
            e = scores_truth - scores_pred 
            se += (e*e).sum(axis = 0)
            cnt += e.size 
        return np.sqrt(se/cnt)
    
    def recommend(self, user_id, top):
        a = np.zeros((self.n_items,))
        recommended_items = []
        items_rated_by_user, score = get_items_rated_by_user(self.Y, user_id)
        # print(self.Yhat)
        for i in range(self.n_items):
            if i not in items_rated_by_user:
                a[i] = self.Yhat[i, user_id]
        if len(a) < top:
            recommended_items = np.argsort(a)[-len(a):]
        else:
            recommended_items = np.argsort(a)[-top:]
        return recommended_items
    
    def evaluatePR(self, Data_test, top, data_size):
        sum_p = 0
        Pu = np.zeros((self.n_users,))
        for u in range(self.n_users):
            recommended_items = self.recommend(u, top)
            ids = np.where(Data_test[:, 0] == u)[0]
            rated_items = Data_test[ids, 1]
            for i in recommended_items:
                if i in rated_items:
                    Pu[u] += 1
            sum_p += Pu[u]
        p = sum_p/(self.n_users * top)
        r = sum_p/(Data_test.shape[0] + 1)
    #     print(sum_p)
        print('%s::%d::%r::%r\r\n' % (str(data_size), top, p, r))

# u_cols =  ['user_id', 'username']
# # user information
# users = pd.read_csv('./users.csv', sep='|', names=u_cols,
#  encoding='latin-1')
# n_users = users.shape[0]

# r_cols = ['user_id', 'product_id', 'rating']

# # user rating product
# ratings_base = pd.read_csv('./ratings.csv', sep='\t', names=r_cols, encoding='latin-1')
# # ratings_test = pd.read_csv('ml-100k/ua.test', sep='\t', names=r_cols, encoding='latin-1')

# rate_train = ratings_base.values
# # rate_test = ratings_test.values

# i_cols = ["product_id", "title", "Others", "Hot", "Cold", "Spicy", "Butter", "Sweet", "Salty", "Greasy", "Bland", "Sour"]

# items = pd.read_csv('./products.csv', sep='|', names=i_cols, encoding='latin-1')
# n_items = items.shape[0]


# X0 = items.values
# X_train_counts = X0[:, -10:]

# cb = Contentbased(rate_train, X_train_counts, n_users= n_users, n_items = n_items, lamda=7)
# cb.fit()

# recommendList = cb.recommend(0, 5)
# print(recommendList)
# for item in recommendList:
#     print(items.values[recommendList[item - 1]][1])
