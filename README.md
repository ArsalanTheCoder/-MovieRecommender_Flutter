# 🎞️ MovieRecommender — Flutter Movie Recommendation System

[![Flutter](https://img.shields.io/badge/Flutter-%20%F0%9F%9A%80-blue)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green)]()
[![Made with ❤️](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red)]()

<p align="center">
  <!-- Banner: clickable (opens your uploaded video/attachment page) -->
  <a href="https://github.com/user-attachments/assets/edb19a33-d414-4705-a33e-4c2e617ac7a9" target="_blank" rel="noopener">
    <img alt="MovieMatch AI Banner" src="https://github.com/user-attachments/assets/b583fcc7-80dd-4e01-a697-9d5177f00b2d" width="1000" />
  </a>
</p>

> **Discover movies you’ll love** — browse TMDB categories, watch trailers, and get ML-powered movie recommendations (TF-IDF → Cosine Similarity).  
> Beautiful Flutter UI • On-device recommendations • Smooth trailer playback 🎬✨

---

## 🔥 Highlights
- 🔎 **Browse** curated categories: Trending, Sci-Fi, Bollywood, Action, Romance, and more.  
- 🔍 **Search** TMDB’s global catalog — find any movie and watch trailers.  
- 🎬 **Movie Details**: cast, crew, release date, synopsis, and trailer playback.  
- 🧠 **ML Recommender**: get similar movies with relevance scores (TF-IDF + Cosine Similarity).  
- ⚡ **Polished Flutter UI** with smooth animations and responsive layout.

---

## 🎥 Demo (click to watch)
- **Full project video** (click the link to open the uploaded video page)  
  https://github.com/user-attachments/assets/d12fbf63-685a-4202-adc5-c1dfab860125

<p align="center">
  <!-- Clickable video thumbnail (click opens your uploaded video page) -->
  <a href="https://github.com/user-attachments/assets/edb19a33-d414-4705-a33e-4c2e617ac7a9" target="_blank" rel="noopener">
    <img src="https://github.com/user-attachments/assets/6a99f69b-37cb-43c1-8ce2-04ff7efab782" alt="MovieRecommender Demo Thumbnail" width="720" />
  </a>
</p>

> **Note:** the URLs above point to GitHub attachment pages. Clicking will open the page where the video is hosted. See the **Video embedding options** section below if you want inline playback directly inside the README.

---

## 📸 Composite Screenshot (Fiverr-style)
One single composite image to showcase the main flows (Home → Search → Detail → Recommendation).

<p align="center">
  <img src="screenshots/composite_screenshots.png" alt="Composite screenshots" width="900" />
</p>

---

## 🧭 Quick Features
- Category carousels & trending lists  
- Fast TMDB search & infinite scroll  
- Trailer playback (YouTube / embedded)  
- Detailed movie pages (credits, metadata)  
- On-device recommender (TF-IDF → Cosine Similarity)  
- Lightweight: pulls metadata from TMDB (no huge local dataset required)

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)  
- **Data:** TMDB API (metadata & trailer links)  
- **Recommender:** TF-IDF + Cosine Similarity (precomputed or light on-device model)  
- **Extras:** Video player plugin, local caching, optional `.tflite` for small models

---

## ⚙️ Quick Start — Install & Run
**Requirements:** Flutter SDK, Android Studio / Xcode (for iOS), a TMDB API key.

```bash
# 1. Clone
git clone https://github.com/<your-username>/movie-recommender-flutter.git
cd movie-recommender-flutter

# 2. Create .env (DO NOT commit .env)
# Example .env content:
# TMDB_API_KEY=your_tmdb_api_key_here

# 3. Clean & install dependencies
flutter clean
flutter pub get

# 4. Run on emulator or device
flutter run

# 5. Build release APK (optional)
flutter build apk --release
# APK located at: build/app/outputs/flutter-apk/app-release.apk
