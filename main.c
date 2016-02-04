#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <cJSON/cJSON.h>

typedef struct Response {
  char *data;
  size_t size;
} Response;

typedef struct Indicator {
  int volume;
  double low;
  double high;
  double open;
  double close;
} Indicator;

typedef struct Quotes {
  char symbol[12];
  char currency[4];
  Indicator *indicators;
  size_t size;
} Quotes;

void Quotes_add(Quotes *quotes, Indicator indicator) {
  if (quotes->size == 0) quotes->indicators = malloc(sizeof(Indicator));
  quotes->size++;
  quotes->indicators = realloc(quotes->indicators, quotes->size * sizeof(Indicator));
  quotes->indicators[quotes->size - 1] = indicator;
}

void Quotes_cleanup(Quotes *quotes) {
  free(quotes->indicators);
  free(quotes);
}

Quotes* Quotes_create(char *json_string) {
  printf("Parsing data for a string with %zu characters.\n", strlen(json_string));

  Quotes *result_struct = malloc(sizeof(Quotes));
  result_struct->size = 0;

  cJSON *json_object = cJSON_Parse(json_string);
  json_object = cJSON_GetObjectItem(json_object, "chart");
  json_object = cJSON_GetObjectItem(json_object, "result");
  json_object = cJSON_GetArrayItem(json_object, 0);

  cJSON *meta_object = cJSON_GetObjectItem(json_object, "meta");

  cJSON *indicators_object = cJSON_GetObjectItem(json_object, "indicators");
  indicators_object = cJSON_GetObjectItem(indicators_object, "quote");
  indicators_object = cJSON_GetArrayItem(indicators_object, 0);

  cJSON *indicators_volume_array = cJSON_GetObjectItem(indicators_object, "volume");
  cJSON *indicators_low_array    = cJSON_GetObjectItem(indicators_object, "low");
  cJSON *indicators_high_array   = cJSON_GetObjectItem(indicators_object, "high");
  cJSON *indicators_open_array   = cJSON_GetObjectItem(indicators_object, "open");
  cJSON *indicators_close_array  = cJSON_GetObjectItem(indicators_object, "close");

  strcpy(result_struct->symbol, cJSON_GetObjectItem(meta_object, "symbol")->valuestring);
  strcpy(result_struct->currency, cJSON_GetObjectItem(meta_object, "currency")->valuestring);
  
  Indicator indicator;

  int indicators_size = cJSON_GetArraySize(indicators_volume_array);
  for (int i = 0; i < indicators_size; i++) {
    indicator.volume = cJSON_GetArrayItem(indicators_volume_array, i)->valueint;
    indicator.low    = cJSON_GetArrayItem(indicators_low_array, i)->valuedouble;
    indicator.high   = cJSON_GetArrayItem(indicators_high_array, i)->valuedouble;
    indicator.open   = cJSON_GetArrayItem(indicators_open_array, i)->valuedouble;
    indicator.close  = cJSON_GetArrayItem(indicators_close_array, i)->valuedouble;
    Quotes_add(result_struct, indicator);
  }

  cJSON_Delete(json_object);

  return result_struct;
}

size_t request_callback(char *content, size_t size, size_t nmemb, void *userdata) {
  size_t length = size * nmemb;
  Response *result = (Response *)userdata;

  result->data = realloc(result->data, result->size + length + 1);
  memcpy(&(result->data[result->size]), content, length);
  result->size += length;
  result->data[result->size] = 0;

  return length;
}

char* request_get(char *url) {
  printf("Making a GET request for %s ...\n", url);

  Response response;
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
  Quotes *quotes = Quotes_create(response_data);
  
  printf("Symbol: %s\n", quotes->symbol);
  printf("Currency: %s\n", quotes->currency);

  printf("Size: %zu\n", quotes->size);

  for (int i = 0; i < quotes->size; i++) {
    printf("V: %i    \t| O: %.2f\t| H: %.2f\t| L: %.2f\t| C: %.2f\n",
        quotes->indicators[i].volume,
        quotes->indicators[i].open,
        quotes->indicators[i].high,
        quotes->indicators[i].low,
        quotes->indicators[i].close
    );
  }

  Quotes_cleanup(quotes);
  free(response_data);

  return 0;
}
