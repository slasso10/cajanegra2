function fn() {
    var config = {
        env: karate.env || 'dev',
        baseUrl: 'https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/'
    };

    karate.configure('connectTimeout', 60000);
    karate.configure('readTimeout', 60000);
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    return config;
}