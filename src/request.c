#include "request.h"

size_t Request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
    size_t length = size * nmemb;
    Response *result = (Response *)userdata;

    result->data = realloc(result->data, result->size + length + 1);
    memcpy(&(result->data[result->size]), content, length);
    result->size += length;
    result->data[result->size] = 0;

    return length;
}

char* Request_get(char *url) {
    printf("Making a GET request for %s ...\n", url);

    Response response;
    response.data = malloc(1);
    response.size = 0;

    CURL *curl;
    curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, Request_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&response);
    curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    return response.data;
}

