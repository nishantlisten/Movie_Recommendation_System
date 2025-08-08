package com.movieapp.servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.*;
import java.util.*;
import org.json.*;

@WebServlet("/recommend")
public class MovieRecommendationServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movie = request.getParameter("movie");
        String rating = request.getParameter("rating");

        // Prepare payload
        JSONObject ratedMovie = new JSONObject();
        ratedMovie.put("title", movie);
        ratedMovie.put("rating", Double.parseDouble(rating));

        JSONArray ratedMovies = new JSONArray();
        ratedMovies.put(ratedMovie);

        JSONObject payload = new JSONObject();
        payload.put("rated_movies", ratedMovies);

        // POST to Python API
        URL url = new URL("http://localhost:5000/recommend_by_rating");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        OutputStream os = conn.getOutputStream();
        os.write(payload.toString().getBytes());
        os.flush();
        os.close();

        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String inputLine;
        StringBuilder responseStr = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            responseStr.append(inputLine);
        }
        in.close();

        JSONObject jsonResponse = new JSONObject(responseStr.toString());
        JSONArray recommended = jsonResponse.getJSONArray("recommended_movies");

        // Prepare list of maps (title + poster)
        List<Map<String, String>> movieDataList = new ArrayList<>();
        for (int i = 0; i < recommended.length(); i++) {
            String title = recommended.getString(i);
            String poster = fetchPoster(title);

            Map<String, String> movieData = new HashMap<>();
            movieData.put("title", title);
            movieData.put("poster", poster);
            movieDataList.add(movieData);
        }

        // Pass data to JSP
        request.setAttribute("movieData", movieDataList);
        request.getRequestDispatcher("result.jsp").forward(request, response);
    }

    private String fetchPoster(String rawTitle) {
        try {
            // Clean the movie title
            String cleanedTitle = rawTitle
                    .replaceAll("\\(.*?\\)", "")  // Remove content in brackets (years)
                    .replaceAll("(?i)a\\.k\\.a\\..*", "")  // Remove a.k.a. parts
                    .replaceAll("[^\\w\\s:\\-']", "")  // Remove special chars (except useful ones)
                    .trim();

            String apiKey = "a9908e8d"; // Replace with your OMDb key
            String query = URLEncoder.encode(cleanedTitle, "UTF-8");

            // Use search instead of title for better match
            URL omdbUrl = new URL("http://www.omdbapi.com/?s=" + query + "&apikey=" + apiKey);
            HttpURLConnection conn = (HttpURLConnection) omdbUrl.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder jsonStr = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonStr.append(line);
            }
            reader.close();

            JSONObject omdbData = new JSONObject(jsonStr.toString());
            if (omdbData.has("Search")) {
                JSONArray searchResults = omdbData.getJSONArray("Search");
                JSONObject firstResult = searchResults.getJSONObject(0);
                if (firstResult.has("Poster") && !firstResult.getString("Poster").equals("N/A")) {
                    return firstResult.getString("Poster");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "https://via.placeholder.com/150x220?text=No+Poster"; // Fallback
    }

}
