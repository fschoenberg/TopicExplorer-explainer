elm make --output elm-te.js src/Main.elm
sudo docker cp elm-te.js `sudo docker ps -q --filter ancestor=hinneburg/topicexplorer-docker:1.1.1`:/topicexplorer/html/explainer/
