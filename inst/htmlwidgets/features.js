CesiumWidget.methods.addFeatures = function(features) {

    var globe = this;

    var promise = Cesium.GeoJsonDataSource.load(features, {
            stroke: Cesium.Color.BLACK.withAlpha(0.9),
            fill: Cesium.Color.BLUE.withAlpha(0.6),
            strokeWidth: 3
        });
    promise.then(function(dataSource) {
        globe.dataSources.add(dataSource);
        var entities = dataSource.entities.values;
        for (var i = 0; i < entities.length; i++) {
            var entity = entities[i];
            entity.billboard = undefined;
            entity.point = new Cesium.PointGraphics({
                color: Cesium.Color.BLUE.withAlpha(0.8),
                pixelSize: 10
            });
        }
        globe.zoomTo(dataSource, new Cesium.HeadingPitchRange(0, -90, 0));
    });
};
