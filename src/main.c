#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <cJSON/cJSON.h>

struct Quotes {
  char symbol[12];
  char currency[3];
};

struct Response {
  char *data;
  size_t size;
};

struct Quotes parse_request_body(char *json_string) {
  printf("Parsing data for a string with %zu characters.\n", strlen(json_string));

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

size_t request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
  size_t length = size * nmemb;
  struct Response *result = (struct Response *)userdata;

  result->data = realloc(result->data, result->size + length + 1);
  memcpy(&(result->data[result->size]), content, length);
  result->size += length;
  result->data[result->size] = 0;

  return length;
}

char* request_get(char *url) {
  printf("Making a GET request for %s ...\n", url);

  struct Response response;
  response.data = malloc(1);
  response.size = 0;

  CURL *curl;
  curl = curl_easy_init();
  curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_callback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&response);
  curl_easy_perform(curl);
  curl_easy_cleanup(curl);

  return response.data;
}

int main(int argc, char const *argv[]) {
  char url[] = "https://finance-yql.media.yahoo.com/v7/finance/chart/PETR4.SA";

  char *response_data = request_get(url);
  struct Quotes quotes = parse_request_body(response_data);
  printf("Symbol: %s\n", quotes.symbol);
  printf("Currency: %s\n", quotes.currency);

  return 0;
}
