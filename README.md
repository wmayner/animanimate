Animanimate
===========

Web-based animation of animat evolution.

Run locally
-----------

First install `nvm`, a [Node.js](http://nodejs.org) version manager:

    curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash

Use it to install the latest stable version of Node:

    nvm install stable

Clone this repo and `cd` into it:

    git clone https://github.com/wmayner/animanimate.git
    cd animanimate

Install the global development dependencies:

    npm install -g gulp

Install the dependencies, build the app, and start local server:

    npm start

Now the page will be available at [http://localhost:5000](http://localhost:5000).

While developing, run `gulp dev` to automatically recompile files:

    gulp dev
