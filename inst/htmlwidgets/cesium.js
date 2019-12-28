HTMLWidgets.widget({

  name: 'cesium',

  type: 'output',

  initialize: function(el, width, height) {

    return {};

  },

  renderValue: function(el, x, instance) {

    if (x.options.imageryProvider === undefined) {
        var osm = Cesium.createOpenStreetMapImageryProvider({
            url : 'https://a.tile.openstreetmap.org/'
        });
        x.options.imageryProvider = osm;
    }

    var options = x.options;

    var cesiumWidget = new Cesium.Viewer(el.id, options);

    // this section is just for poc to load data!! delete once
    // proper add* functions have been created
    var promise = Cesium.GeoJsonDataSource.load(x.cesiumData, {
        stroke: Cesium.Color.BLACK.withAlpha(0.9),
        fill: Cesium.Color.BLUE.withAlpha(0.6),
        strokeWidth: 3
    });
    promise.then(function(dataSource) {
        cesiumWidget.dataSources.add(dataSource);
        var entities = dataSource.entities.values;
        for (var i = 0; i < entities.length; i++) {
            var entity = entities[i];
            entity.billboard = undefined;
            entity.point = new Cesium.PointGraphics({
                color: Cesium.Color.BLUE.withAlpha(0.8),
                pixelSize: 10
            });
        }
        cesiumWidget.zoomTo(dataSource, new Cesium.HeadingPitchRange(0, -90, 0));
    });

  },

  resize: function(el, width, height, instance) {

  }

});
