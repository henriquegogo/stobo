#include "quotes.h"

void Quotes_add(Quotes *quotes, Indicator indicator) {
    if (quotes->size == 0) quotes->indicators = malloc(sizeof(Indicator));
    quotes->size++;
    quotes->indicators = realloc(quotes->indicators, quotes->size * sizeof(Indicator));
    quotes->indicators[quotes->size - 1] = indicator;
}

void Quotes_cleanup(Quotes *quotes) {
    free(quotes->indicators);
    quotes->indicators = NULL;
    free(quotes);
    quotes = NULL;
}

Quotes* Quotes_create(char *json_string) {
    printf("Parsing data for a string with %zu characters.\n", strlen(json_string));

    Quotes *result_struct = malloc(sizeof(Quotes));
    result_struct->size = 0;

    cJSON *json_object = cJSON_Parse(json_string);
    free(json_string);
    json_string = NULL;
    json_object = cJSON_GetObjectItem(json_object, "chart");
    json_object = cJSON_GetObjectItem(json_object, "result");
    json_object = cJSON_GetArrayItem(json_object, 0);

    cJSON *meta_object = cJSON_GetObjectItem(json_object, "meta");
    cJSON *timestamp_array = cJSON_GetObjectItem(json_object, "timestamp");

    cJSON *indicators_object = cJSON_GetObjectItem(json_object, "indicators");
    indicators_object = cJSON_GetObjectItem(indicators_object, "quote");
    indicators_object = cJSON_GetArrayItem(indicators_object, 0);
    // TODO: Verify if indicators_object is NULL (begin of session)

    cJSON *indicators_volume_array = cJSON_GetObjectItem(indicators_object, "volume");
    cJSON *indicators_low_array    = cJSON_GetObjectItem(indicators_object, "low");
    cJSON *indicators_high_array   = cJSON_GetObjectItem(indicators_object, "high");
    cJSON *indicators_open_array   = cJSON_GetObjectItem(indicators_object, "open");
    cJSON *indicators_close_array  = cJSON_GetObjectItem(indicators_object, "close");

    strcpy(result_struct->symbol, cJSON_GetObjectItem(meta_object, "symbol")->valuestring);
    strcpy(result_struct->currency, cJSON_GetObjectItem(meta_object, "currency")->valuestring);

    Indicator indicator;

    int indicators_size = cJSON_GetArraySize(timestamp_array);
    for (int i = 0; i < indicators_size; i++) {
        indicator.timestamp = cJSON_GetArrayItem(timestamp_array, i)->valueint;
        indicator.volume    = cJSON_GetArrayItem(indicators_volume_array, i)->valueint;
        indicator.low       = cJSON_GetArrayItem(indicators_low_array, i)->valuedouble;
        indicator.high      = cJSON_GetArrayItem(indicators_high_array, i)->valuedouble;
        indicator.open      = cJSON_GetArrayItem(indicators_open_array, i)->valuedouble;
        indicator.close     = cJSON_GetArrayItem(indicators_close_array, i)->valuedouble;
        Quotes_add(result_struct, indicator);
    }

    cJSON_Delete(json_object);

    return result_struct;
}
