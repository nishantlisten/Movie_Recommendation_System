from flask import Flask, request, jsonify
import pandas as pd
import pickle
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
# Load data
movies = pd.read_csv('movies_cleaned.csv')

user_similarity = pickle.load(open('user_similarity.pkl', 'rb'))
user_movie_matrix = pickle.load(open('user_movie_matrix.pkl', 'rb'))

@app.route('/')
def home():
    return '''
    <h2>🎬 Welcome to the Movie Recommendation API!</h2>
    <p>Use <code>/recommend?user_index=1</code> (GET)</p>
    <p>Or send a JSON POST to <code>/recommend</code> like:<br>
    <code>{"user_index": 1}</code></p>
    '''

# 🔹 Support both GET and POST
@app.route('/recommend', methods=['GET', 'POST'])
def recommend():
    try:
        if request.method == 'POST':
            data = request.get_json()
            user_index = int(data.get('user_index'))
        else:
            user_index = int(request.args.get('user_index'))

        if user_index >= len(user_similarity):
            return jsonify({'error': 'User index out of range'}), 400

        sim_scores = list(enumerate(user_similarity[user_index]))
        sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
        top_users = [i[0] for i in sim_scores[1:6]]

        recommendations = set()
        for similar_user in top_users:
            top_movies = user_movie_matrix.iloc[similar_user].sort_values(ascending=False)
            recommended = top_movies[top_movies > 4].index.tolist()[:5]
            recommendations.update(recommended)

        movie_titles = movies[movies['movieId'].isin(recommendations)]['title'].tolist()
        return jsonify({'recommended_movies': movie_titles})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/recommend_by_rating', methods=['POST'])
def recommend_by_rating():
    try:
        data = request.get_json()
        rated_movies = data.get('rated_movies', [])

        if not rated_movies:
            return jsonify({'error': 'No movies rated'}), 400

        # Load movie data & similarity
        movie_titles = movies['title'].tolist()
        similarity = pickle.load(open('content_similarity.pkl', 'rb'))

        movie_scores = {}

        for entry in rated_movies:
            title = entry['title']
            rating = entry['rating']
            if title in movie_titles:
                idx = movie_titles.index(title)
                sim_scores = list(enumerate(similarity[idx]))
                for i, score in sim_scores:
                    if i not in movie_scores:
                        movie_scores[i] = 0
                    movie_scores[i] += score * rating

        # Sort movies based on score
        sorted_scores = sorted(movie_scores.items(), key=lambda x: x[1], reverse=True)

        # Get top 10 recommendations, avoid duplicates
        recommended = []
        rated_titles = [m['title'] for m in rated_movies]
        for i, _ in sorted_scores:
            movie = movie_titles[i]
            if movie not in rated_titles:
                recommended.append(movie)
            if len(recommended) == 10:
                break

        return jsonify({'recommended_movies': recommended})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
