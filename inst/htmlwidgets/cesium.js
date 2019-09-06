HTMLWidgets.widget({

  name: 'cesium',

  type: 'output',

  initialize: function(el, width, height) {

    return {};

  },

  renderValue: function(el, x, instance) {

    var osm = Cesium.createOpenStreetMapImageryProvider({
        url : 'https://a.tile.openstreetmap.org/'
    });

    var options = {
        animation: false,
        baseLayerPicker: false,
        fullscreenButton: false,
        geocoder: false,
        homeButton: true,
        infoBox: false,
        sceneModePicker: true,
        selectionIndicator: false,
        timeline: true,
        navigationHelpButton: false,
        navigationInstructionsInitiallyVisible: false,
        scene3DOnly: false,
        skyBox: new Cesium.SkyBox({ show: false }),
        skyAtmosphere: false,
        sceneMode: Cesium.SceneMode.SCENE3D,
        imageryProvider: osm,
        /*new Cesium.BingMapsImageryProvider({
            url : '//dev.virtualearth.net',
            key: "AmQpyJ0dJni-9bvaRNx_7CHPxbx4BS951EdUOv1-qmkE-DDDX_e8W6F1GRuEK3Ya",
            mapStyle : Cesium.BingMapsStyle.AERIAL
        }),*/
        targetFrameRate: 100,
        orderIndependentTranslucency: false,
        contextOptions: {
                          webgl : {
                                    alpha : false,
                                    depth : false,
                                    stencil : false,
                                    antialias : false,
                                    premultipliedAlpha : true,
                                    preserveDrawingBuffer : false,
                                    failIfMajorPerformanceCaveat : false
                                  },
                          allowTextureFilterAnisotropic : false
                        },
        projectionPicker: true
    };

    var cesiumWidget = new Cesium.Viewer(el.id, options);

  },

  resize: function(el, width, height, instance) {

  }

});
