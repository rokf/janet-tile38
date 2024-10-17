(declare-project
  :name "janet-tile38"
  :author "Rok Fajfar <hi@rokf.dev>"
  :description "A Janet client library for Tile38"
  :license "MIT"
  :version "0.0.1"
  :url "https://github.com/rokf/janet-tile38"
  :repo "git+https://github.com/rokf/janet-tile38"
  :dependencies [{:url "https://github.com/rokf/janet-resp" :tag "main"}])

(declare-source
  :prefix "tile38"
  :source ["src/init.janet"])
