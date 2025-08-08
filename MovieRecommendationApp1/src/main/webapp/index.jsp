<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.nio.file.*, java.io.*" %>
<%
    // Load movie titles from CSV
    List<String> movieTitles = new ArrayList<>();
    try {
        List<String> lines = Files.readAllLines(Paths.get(application.getRealPath("/movies.csv")));
        for (String line : lines.subList(1, lines.size())) { // Skip header
            String[] parts = line.split(",");
            if (parts.length > 1) {
                movieTitles.add(parts[1].replaceAll("\"", "").trim()); // Clean quotes
            }
        }
        Collections.sort(movieTitles); // Optional: Sort alphabetically
    } catch (IOException e) {
        e.printStackTrace();
    }
%>

<html>
<head>
    <title>Movie Recommender</title>
    <style>
        body {
            background-color: #121212;
            color: white;
            font-family: Arial, sans-serif;
            padding: 40px;
            text-align: center;
        }

        form {
            background-color: #1e1e1e;
            padding: 30px;
            border-radius: 10px;
            display: inline-block;
        }

        select, input[type="number"], input[type="submit"] {
            padding: 10px;
            margin: 10px 0;
            width: 300px;
            font-size: 16px;
            border-radius: 5px;
            border: none;
        }

        input[type="submit"] {
            background-color: #2196F3;
            color: white;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #0b7dda;
        }
    </style>
</head>
<body>

    <h2>🎬 Movie Recommendation System</h2>

    <form method="post" action="recommend">
        <label for="movie">Choose a movie:</label><br>
        <select id="movie" name="movie" required>
            <option value="">-- Select a movie --</option>
            <% for(String title : movieTitles) { %>
                <option value="<%= title %>"><%= title %></option>
            <% } %>
        </select><br>

        <label for="rating">Your Rating (0.0 to 5.0):</label><br>
        <input type="number" id="rating" name="rating" step="0.5" min="0" max="5" required><br>

        <input type="submit" value="Get Recommendations">
    </form>

</body>
</html>
