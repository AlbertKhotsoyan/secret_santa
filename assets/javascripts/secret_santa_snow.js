(function() {
  'use strict';

  var CONTAINER_ID = 'secret-santa-snowfall';
  var FOREST_ID = 'secret-santa-forest';
  var FLAKE_COUNT = 38;
  var SPRITE_VARIANTS = 7;
  var FOREST_LAYOUT = [
    { variant: 4, size: 'md', side: 'left' },
    { variant: 3, size: 'sm', side: 'right' },
    { variant: 8, size: 'md', side: 'right' }
  ];

  function randomBetween(min, max) {
    return min + Math.random() * (max - min);
  }

  function createSnowflake(index) {
    var flake = document.createElement('span');
    var variant = (index % SPRITE_VARIANTS) + 1;
    var size = Math.round(randomBetween(14, 30));
    var left = randomBetween(1, 98).toFixed(2);
    var duration = randomBetween(10, 20).toFixed(2);
    var delay = (-randomBetween(0, 20)).toFixed(2);
    var sway = Math.round(randomBetween(-36, 36));
    var rotation = Math.round(randomBetween(180, 360)) * (Math.random() > 0.5 ? 1 : -1);
    var opacity = randomBetween(0.45, 0.88).toFixed(2);

    flake.className = 'secret-santa-snowflake secret-santa-snowflake--' + variant;
    flake.style.width = size + 'px';
    flake.style.height = size + 'px';
    flake.style.left = left + '%';
    flake.style.opacity = opacity;
    flake.style.animationDuration = duration + 's';
    flake.style.animationDelay = delay + 's';
    flake.style.setProperty('--ss-snow-sway', sway + 'px');
    flake.style.setProperty('--ss-snow-rot', rotation + 'deg');

    return flake;
  }

  function createForest() {
    var forest = document.createElement('div');
    forest.id = FOREST_ID;
    forest.className = 'secret-santa-forest';
    forest.setAttribute('aria-hidden', 'true');

    var leftGroup = document.createElement('div');
    leftGroup.className = 'secret-santa-forest-group';

    var rightGroup = document.createElement('div');
    rightGroup.className = 'secret-santa-forest-group';

    for (var i = 0; i < FOREST_LAYOUT.length; i++) {
      var item = FOREST_LAYOUT[i];
      var tree = document.createElement('span');
      tree.className =
        'secret-santa-tree secret-santa-tree--' +
        item.variant +
        ' secret-santa-tree--' +
        item.size;
      if (item.side === 'left') {
        leftGroup.appendChild(tree);
      } else {
        rightGroup.appendChild(tree);
      }
    }

    forest.appendChild(leftGroup);
    forest.appendChild(rightGroup);
    return forest;
  }

  function initSecretSantaSnow() {
    var page = document.querySelector('.secret-santa-page');
    if (!page) {
      return;
    }

    if (!document.getElementById(FOREST_ID)) {
      page.appendChild(createForest());
    }

    if (!document.getElementById(CONTAINER_ID)) {
      var container = document.createElement('div');
      container.id = CONTAINER_ID;
      container.className = 'secret-santa-snowfall';
      container.setAttribute('aria-hidden', 'true');

      var fragment = document.createDocumentFragment();
      for (var i = 0; i < FLAKE_COUNT; i++) {
        fragment.appendChild(createSnowflake(i));
      }

      container.appendChild(fragment);
      page.appendChild(container);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSecretSantaSnow);
  } else {
    initSecretSantaSnow();
  }

  document.addEventListener('turbo:load', initSecretSantaSnow);
})();
