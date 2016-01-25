#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
//#include <cJSON/cJSON.h>

char *result;

size_t request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
  size_t length = size * nmemb;
  size_t result_size = result ? strlen(result) * sizeof(char) : 0;

  result = realloc(result, result_size + length + 1);
  memcpy(&result[result_size], content, length);
  result_size += length;
  result[result_size] = 0;

  return length;
}

int main(int argc, char const *argv[]) {
  char url[] = "https://finance-yql.media.yahoo.com/v7/finance/chart/PETR4.SA";
  CURL *curl;

  curl = curl_easy_init();

  curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_callback);
  curl_easy_perform(curl);

  printf("%s\n", result);

  /*
  cJSON *json_object = cJSON_Parse(result);
  json_object = cJSON_GetObjectItem(json_object, "chart");
  json_object = cJSON_GetObjectItem(json_object, "result");
  json_object = cJSON_GetArrayItem(json_object, 0);
  json_object = cJSON_GetObjectItem(json_object, "meta");
  json_object = cJSON_GetObjectItem(json_object, "symbol");
  printf("%s\n", json_object->valuestring);

  cJSON_Delete(json_object);
  */

  free(result);
  curl_easy_cleanup(curl);

  return 0;
}
