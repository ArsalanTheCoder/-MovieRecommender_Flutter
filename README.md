# 🎞️ MovieRecommender — Flutter Movie Recommendation System

[![Flutter](https://img.shields.io/badge/Flutter-%20%F0%9F%9A%80-blue)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green)]()
[![Made with ❤️](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red)]()

<p align="center">
  <!-- Banner (clickable to open project video) -->
  <a href="https://github.com/user-attachments/assets/edb19a33-d414-4705-a33e-4c2e617ac7a9" target="_blank" rel="noopener">
    <img alt="MovieMatch AI Banner" src="https://github.com/user-attachments/assets/b583fcc7-80dd-4e01-a697-9d5177f00b2d" width="1000" />
  </a>
</p>

> **Discover movies you’ll love** — browse TMDB categories, watch trailers, and get ML-powered movie recommendations (TF-IDF → Cosine Similarity).  
> Beautiful Flutter UI • On-device recommendations • Smooth trailer playback 🎬✨

---

## 🔥 Highlights
- 🔎 **Browse** curated categories: Trending, Sci-Fi, Bollywood, Action, Romance, and more.  
- 🔍 **Search** the TMDB catalog — find any movie worldwide.  
- 🎬 **Movie Details**: cast, crew, release date, synopsis, and play trailers.  
- 🧠 **ML Recommender**: get similar movies with relevance scores based on TF-IDF + Cosine Similarity.  
- ⚡ **Polished Flutter UI** with smooth animations and responsive layout.

---

## 🎥 Demo (click to watch)
- Full project video (click):  

https://github.com/user-attachments/assets/d12fbf63-685a-4202-adc5-c1dfab860125


  

<p align="center">
  <!-- Video thumbnail links to full video -->
  <a href="https://github.com/user-attachments/assets/edb19a33-d414-4705-a33e-4c2e617ac7a9" target="_blank" rel="noopener">
    <img src="https://github.com/user-attachments/assets/6a99f69b-37cb-43c1-8ce2-04ff7efab782" alt="MovieRecommender Demo Thumbnail" width="720" />
  </a>
</p>

> If you prefer a GIF demo, place `screenshots/demo.gif` in the repo and replace the thumbnail above.

---

## 📸 Single Composite Screenshots (Fiverr-style)
I combined all screenshots into one clean image (ideal for presentations / portfolio). Use this single image to showcase flows (Home → Search → Details → Recommendation).

<p align="center">
  <img src="screenshots/composite_screenshots.png" alt="Composite screenshots" width="900" />
</p>

---

## 🧭 Quick Features
- Category carousels & trending lists  
- Fast TMDB search & infinite scroll  
- Trailer playback (YouTube / embedded)  
- Detailed movie pages (credits, metadata)  
- On-device ML recommender using TF-IDF vectors + Cosine Similarity  
- Lightweight: relies on TMDB API (no huge local DB required)

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)  
- **Data source:** TMDB API (metadata & trailer links)  
- **Recommender:** TF-IDF + Cosine Similarity (precompute or on-device)  
- **Extras:** Video player plugin, local caching, optional `.tflite` for small models

---

## ⚙️ Quick Start — Install & Run (one-shot)
**Requirements:** Flutter SDK, Android Studio / Xcode (for iOS), a TMDB API key.

```bash
# 1. Clone
git clone https://github.com/<your-username>/movie-recommender-flutter.git
cd movie-recommender-flutter

# 2. Create env (do NOT commit .env)
# create a file named .env in the project root with:
# TMDB_API_KEY=your_tmdb_api_key_here

# 3. Clean & install
flutter clean
flutter pub get

# 4. Run (emulator or connected device)
flutter run

# 5. Build release APK (optional)
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
