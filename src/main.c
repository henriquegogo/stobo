#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

char url[] = "https://finance-yql.media.yahoo.com/v7/finance/chart/PETR4.SA";
char *result;
size_t result_size;
CURL *curl;

size_t request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
  size_t length = size * nmemb;

  result = realloc(result, result_size + length + 1);
  memcpy(&result[result_size], content, length);
  result_size += length;
  result[result_size] = 0;

  return length;
}

int main(int argc, char const *argv[]) {
  curl = curl_easy_init();

  curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_callback);
  curl_easy_perform(curl);

  printf("%s\n", result);

  free(result);
  curl_easy_cleanup(curl);

  return 0;
}
