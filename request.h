#ifndef REQUEST_H
#define REQUEST_H

#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

typedef struct Response {
    char *data;
    size_t size;
} Response;

size_t Request_callback(char *content, size_t size, size_t nmemb, void *userdata);

char* Request_get(char *url);

#endif
