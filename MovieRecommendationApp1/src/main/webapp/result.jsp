<%@ page import="java.util.*,java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Recommendations</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #121212;
            color: white;
            text-align: center;
            margin: 0;
            padding: 20px;
        }

        h1 {
            margin-bottom: 30px;
        }

        .movie-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
        }

        .movie {
            background-color: #1f1f1f;
            border-radius: 12px;
            margin: 15px;
            padding: 15px;
            width: 200px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.4);
            transition: transform 0.2s ease;
        }

        .movie:hover {
            transform: scale(1.05);
        }

        img {
            width: 100%;
            height: 270px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        h4 {
            font-size: 16px;
            margin: 5px 0;
            color: #f0f0f0;
        }

        .back-button {
            margin-top: 30px;
        }

        .back-button a {
            text-decoration: none;
            color: white;
            background-color: #2196F3;
            padding: 10px 20px;
            border-radius: 6px;
        }

        .back-button a:hover {
            background-color: #0b7dda;
        }
    </style>
</head>
<body>

    <h1>🎥 Recommended Movie for You</h1>

    <div class="movie-container">
    <%
        List<Map<String, String>> movieList = (List<Map<String, String>>) request.getAttribute("movieData");
        if (movieList != null && !movieList.isEmpty()) {
            for (Map<String, String> movie : movieList) {
    %>
        <div class="movie">
            <img src="<%= movie.get("poster") %>" alt="Poster not available">
            <h4><%= movie.get("title") %></h4>
        </div>
    <%
            }
        } else {
    %>
        <p>No recommendations available.</p>
    <%
        }
    %>
    </div>

    <div class="back-button">
        <a href="index.jsp">🔙 Back to Home</a>
    </div>

</body>
</html>
