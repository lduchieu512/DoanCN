from sklearn.metrics.pairwise import linear_kernel
from sklearn.feature_extraction.text import TfidfVectorizer
import pandas
from pandas import read_csv, isnull, notnull

def getDataFrameProductsCsv(text):
    product_cols = ['productid', 'title', 'genres']
    products = pandas.read_csv(text, sep=',', names=product_cols, encoding='latin-1')
    return products

def cosine_sim(matrix):
    """
            Dùng hàm "linear_kernel" để tạo thành ma trận hình vuông với số hàng và số cột là số lượng product
             để tính toán điểm tương đồng giữa từng sản phẩm với nhau
    """
    new_cosine_sim = linear_kernel(matrix, matrix)
    return new_cosine_sim

def tfidf_matrix(productList):
    """
        Dùng hàm "TfidfVectorizer" để chuẩn hóa "type" với:
        + analyzer='word': chọn đơn vị trích xuất là word
        + ngram_range=(1, 1): mỗi lần trích xuất 1 word
        + min_df=0: tỉ lệ word không đọc được là 0
        Lúc này ma trận trả về với số dòng tương ứng với số lượng product và số cột tương ứng với số từ được tách ra từ "type"
    """
    tf = TfidfVectorizer(analyzer='word', ngram_range=(1, 1), min_df=0)
    new_tfidf_matrix = tf.fit_transform(productList['genres'])
    return new_tfidf_matrix