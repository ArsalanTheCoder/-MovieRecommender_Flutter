# 🎞️ MovieRecommender — Flutter Movie Recommendation System

[![Flutter](https://img.shields.io/badge/Flutter-%20%F0%9F%9A%80-blue)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green)]()
[![Made with ❤️](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red)]()

> Discover movies you’ll love — browse TMDB categories, watch trailers, and get ML-powered movie recommendations (TF-IDF + Cosine Similarity).  
> Beautiful Flutter UI • On-device recommendations • Smooth trailer playback 🎬✨

---

## 🔥 Highlights
- 🔎 **Browse** curated categories: Trending, Sci-Fi, Bollywood, Action, Romance, and more.  
- 🔍 **Global Search** powered by TMDB metadata — find any movie worldwide.  
- 🎬 **Movie Details**: cast, crew, release date, synopsis, and play trailers directly.  
- 🧠 **ML Recommender**: input a movie → receive similar movies with relevance scores (TF-IDF + Cosine Similarity).  
- ⚡ **Polished Flutter UI** with smooth animations, responsive layouts, and offline-friendly design.

---

## 🎥 Demo / Screenshots
> Replace these with your `screenshots/` or `assets/demo.gif` raw links.

<p align="center">
  <img src="screenshots/demo.gif" alt="Demo GIF" width="720" />
</p>
https://github.com/user-attachments/assets/edb19a33-d414-4705-a33e-4c2e617ac7a9 



<p align="center">
  <img src="screenshots/home.png" width="300" alt="Home - Categories" style="margin:8px">
  <img src="screenshots/search.png" width="300" alt="Search" style="margin:8px">
  <img src="screenshots/detail.png" width="300" alt="Movie Detail & Trailer" style="margin:8px">
</p>

<img width="1920" height="1005" alt="MovieMatch AI Banner" src="https://github.com/user-attachments/assets/6a99f69b-37cb-43c1-8ce2-04ff7efab782" />


---

## 🧭 Quick Features
- Category carousels & trending lists  
- Fast TMDB search & infinite scroll  
- Trailer playback (YouTube / embedded)  
- Detailed movie pages (credits, metadata)  
- On-device ML recommender using TF-IDF vectors + Cosine Similarity (fast & private)  
- Handles large catalogs via TMDB API (no local huge dataset required)

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)  
- **Data source:** TMDB (The Movie Database) API  
- **ML:** TF-IDF vectorization + Cosine Similarity (precomputed vectors or light on-device model / tflite)  
- **Extras:** video player plugin for trailers, local caching for smoother UX

---

## ⚙️ Quick Start — Run Locally

> **Before you start**: get a TMDB API key at https://www.themoviedb.org/settings/api

1. **Clone**
```bash
git clone https://github.com/<your-username>/movie-recommender-flutter.git
cd movie-recommender-flutter
