#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <cJSON/cJSON.h>

char *result;

struct Quotes {
  char symbol[12];
  char currency[3];
};

size_t request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
  size_t length = size * nmemb;
  size_t result_size = result ? strlen(result) * sizeof(char) : 0;

  result = realloc(result, result_size + length + 1);
  memcpy(&result[result_size], content, length);
  result_size += length;
  result[result_size] = 0;

  return length;
}

struct Quotes parse_request_body(char *json_string) {
  struct Quotes result_struct;

  cJSON *json_object = cJSON_Parse(json_string);
  json_object = cJSON_GetObjectItem(json_object, "chart");
  json_object = cJSON_GetObjectItem(json_object, "result");
  json_object = cJSON_GetArrayItem(json_object, 0);
  json_object = cJSON_GetObjectItem(json_object, "meta");

  char *symbol = cJSON_GetObjectItem(json_object, "symbol")->valuestring;
  char *currency = cJSON_GetObjectItem(json_object, "currency")->valuestring;

  strcpy(result_struct.symbol, symbol);
  strcpy(result_struct.currency, currency);

  cJSON_Delete(json_object);

  return result_struct;
}

char* request_get(char *url) {
  CURL *curl;
  curl = curl_easy_init();
  curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_callback);
  curl_easy_perform(curl);
  curl_easy_cleanup(curl);

  return result;
}

int main(int argc, char const *argv[]) {
  char url[] = "https://finance-yql.media.yahoo.com/v7/finance/chart/PETR4.SA";

  request_get(url);
  struct Quotes quotes = parse_request_body(result);
  printf("Symbol: %s\n", quotes.symbol);
  printf("Currency: %s\n", quotes.currency);

  free(result);

  return 0;
}
