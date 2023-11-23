import pandas as pd
from processing import *

class CB(object):
    """
        Khởi tại dataframe "productList" với hàm "getDataFrameProductsCsv"
    """
    def __init__(self, movies_csv):
        self.productList = getDataFrameProductsCsv(movies_csv)
        self.tfidf_matrix = None
        self.cosine_sim = None

    def build_model(self):
        """
            Tách các giá trị của type ở từng product đang được ngăn cách bởi '|'
        """
        self.productList['genres'] = self.productList['genres'].str.split('|')
        self.productList['genres'] = self.productList['genres'].fillna("").astype('str')
        self.tfidf_matrix = tfidf_matrix(self.productList)
        self.cosine_sim = cosine_sim(self.tfidf_matrix)

    def refresh(self):
        """
             Chuẩn hóa dữ liệu và tính toán lại ma trận
        """
        self.build_model()

    def fit(self):
        self.refresh()
    
    def genre_recommendations(self, title, top_x):
        """
            Xây dựng hàm trả về danh sách top product tương đồng theo tên product truyền vào:
            + Tham số truyền vào gồm "title" là tên product và "topX" là top product tương đồng cần lấy
            + Tạo ra list "sim_score" là danh sách điểm tương đồng với product truyền vào
            + Sắp xếp điểm tương đồng từ cao đến thấp
            + Trả về top danh sách tương đồng cao nhất theo giá trị "topX" truyền vào
        """
        titles = self.productList['productid']
        indices = pd.Series(self.productList.index, index=self.productList['productid'])
        idx = indices[title]
        print(idx)
        sim_scores = list(enumerate(self.cosine_sim[idx]))
        print(sim_scores)
        sim_scores.pop(0)
        sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)

        sim_scores = sim_scores[1:top_x + 1]
        
        product_indices = [i[0] for i in sim_scores]
        return sim_scores, titles.iloc[product_indices].values
