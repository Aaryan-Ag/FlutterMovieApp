# 🎬 Flutter Movie App

A beautiful and responsive **Flutter Movie App** built with the **TMDB API**, featuring real-time search, caching, deep linking, and offline support.  
Users can explore trending and now-playing movies, save favorites, and share movie details via generated links.

---

## ✨ Features

- 🔥 **Trending & Now Playing** – Fetch movies from TMDB API.
- ⚡ **Caching** – Local caching for faster reloads and reduced API calls.
- 🔄 **Pull-to-Refresh** – Force refresh data anytime.
- 💾 **Favorites** – Save and delete favorite movies locally.
- 🔍 **Real-time Search** – Instant movie search with debounce optimization.
- 🔗 **Deep Link Simulation** – Share movies with a fake deep link that opens the app directly to that movie’s details page.
- 📱 **Responsive UI** – Works on both Android and iOS.

---

## 🧩 Tech Stack

- **Flutter**
- **Dart**
- **TMDB API**
- Bloc (for state management)
- Hive (for caching & favorites)
- dio (for network calls)
- share_plus (for sharing deep links)

---

## 🚀 Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/Aaryan-Ag/FlutterMovieApp.git
   cd FlutterMovieApp
