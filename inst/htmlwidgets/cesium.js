HTMLWidgets.widget({

  name: 'cesium',

  type: 'output',

  initialize: function(el, width, height) {

    return {};

  },

  renderValue: function(el, x, instance) {

    var options = {
        animation: false,
        baseLayerPicker: false,
        fullscreenButton: false,
        geocoder: false,
        homeButton: false,
        infoBox: false,
        sceneModePicker: false,
        selectionIndicator: false,
        timeline: false,
        navigationHelpButton: false,
        navigationInstructionsInitiallyVisible: false,
        scene3DOnly: true,
        skyBox: new Cesium.SkyBox({ show: false }),
        skyAtmosphere: false,
        sceneMode: Cesium.SceneMode.SCENE2D,
        imageryProvider: new Cesium.OpenStreetMapImageryProvider(),
        targetFrameRate: 1,
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
                        }
    };

    var viewer = new Cesium.Viewer(el.id, options);

  },

  resize: function(el, width, height, instance) {

  }

});
