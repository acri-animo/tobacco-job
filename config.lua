availableTobJobs = {
    ----------------------
    -- Picking wet tobacco
    ----------------------
    {
        objective = "Harvest Tobacco Plants",
        action = "Harvesting Tobacco",
        durationBase = 60,
        animation = {
            task = "WORLD_HUMAN_GARDENER_PLANT",
        },
        locationSets = {
            {
                { id = 1, coords = vector3(32.692, 2923.589, 55.505) },
                { id = 2, coords = vector3(32.594, 2929.333, 55.597) },
                { id = 3, coords = vector3(40.051, 2946.448, 55.638) },
                { id = 4, coords = vector3(50.292, 2941.542, 55.605) },
                { id = 5, coords = vector3(53.621, 2934.565, 55.595) },
                { id = 6, coords = vector3(46.137, 2955.717, 55.514) },
                { id = 7, coords = vector3(55.752, 2956.840, 55.475) },
                { id = 8, coords = vector3(64.704, 2947.308, 55.565) },
                { id = 9, coords = vector3(67.372, 2935.748, 55.578) },
                { id = 10, coords = vector3(58.681, 2939.524, 55.619) },
            },
        },
    },
    -----------------
    -- Drying tobacco
    -----------------
    {
        objective = "Dry Wet Tobacco",
        action = "Drying Wet Tobacco",
        durationBase = 90,
        animation = {
            task = "PROP_HUMAN_PARKING_METER",
        },
        locationSets = {
            {
                { id = 1, coords = vector3(-65.406, 2905.704, 59.099) },
                { id = 2, coords = vector3(-64.437, 2905.195, 59.099) },
                { id = 3, coords = vector3(-63.865, 2904.857, 59.099) },
                { id = 4, coords = vector3(-63.134, 2904.556, 59.099) },
                { id = 5, coords = vector3(-62.452, 2904.302, 59.099) },
                { id = 6, coords = vector3(-61.707, 2901.731, 59.099) },
                { id = 7, coords = vector3(-61.909, 2900.921, 59.099) },
                { id = 8, coords = vector3(-62.257, 2900.410, 59.099) },
                { id = 9, coords = vector3(-62.456, 2899.809, 59.099) },
                { id = 10, coords = vector3(-63.100, 2899.038, 59.099) },
            },
        },
    },
    ---------------------
    -- Processing tobacco
    ---------------------
    {
        objective = "Process Dried Tobacco",
        action = "Processing Dry Tobacco",
        durationBase = 120,
        animation = {
            task = "PROP_HUMAN_PARKING_METER",
        },
        locationSets = {
            {
                { id = 1, coords = vector3(-58.943, 2910.590, 59.099) },
                { id = 2, coords = vector3(-57.729, 2909.967, 59.099) },
                { id = 3, coords = vector3(-56.479, 2909.301, 59.099) },
                { id = 4, coords = vector3(-55.445, 2908.751, 59.099) },
                { id = 5, coords = vector3(-54.256, 2910.621, 59.099) },
                { id = 6, coords = vector3(-55.319, 2911.244, 59.099) },
                { id = 7, coords = vector3(-56.672, 2911.956, 59.099) },
                { id = 8, coords = vector3(-57.639, 2912.430, 59.099) },
                { id = 9, coords = vector3(-51.698, 2908.768, 59.099) },
                { id = 10, coords = vector3(-49.902, 2903.288, 59.099) },
            },
        },
    },
}
