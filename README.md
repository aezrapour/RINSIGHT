# RINSIGHT - Real-time Interactive Neural Sensory Integration Glasses for Hearing Technology


## Capstone Expo 2024 Setup

1. Python Websocket server
2. Flutter Application
3. Esp32 firmware
4. Mobile hotspot or wifi connection to allow communication between flutter app and esp32


## Start Python websocket server:

1. Launch python env
2. use `rinsight_websocket_server_v2`:

```sh
cd rinsight_websocket_server_v2
```

3. Install dependencies
```sh
pip install -r requirements.txt
```

4. start server
```sh
python app.py
```

This should start the websocket server on your machine on port 8887


## Changes for ESP32 firmware code

In `include/ossg_constants.hpp`:

```cpp
static char *esp_wifi_ssid = "Your hotspot / wifi SSID";
static char *esp_wifi_pass = "Your hotspot / wifi password";
```


In `src/comms/wifi_websocket_comms.cpp`, change the following elseif block (line 329) to below:
```cpp
else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP)
    {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
        ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
        snprintf(WIS_IP, sizeof(WIS_IP), "Your Laptop's IP address");
        snprintf(WIS_WEBSOCKET_IP, sizeof(WIS_WEBSOCKET_IP), "Your Laptop's IP address");
        printf("WIS_IP is %s", WIS_IP);
        printf("WIS_WEBSOCKET_IP is %s", WIS_WEBSOCKET_IP);
        update_ws_ip();
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
        // start listening for UDP packets - WIS server advertising itself
        // xTaskCreate(&udp_listen_task, "udp_listen_thread", 2048, NULL, 5, NULL);
        // xTaskCreate(&tcp_connect_task, "tcp_connect_thread", 2048, NULL, 5, NULL);
    }
```

Make sure to update `Your Laptop's IP address` in the code above to your laptop's IP address for where the websocket server is running from. Be sure to compile and upload code to esp32.