package com.example.varnishdemoapp;

import javax.servlet.http.HttpServlet;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;

import io.prometheus.client.exporter.MetricsServlet;
import io.prometheus.client.hotspot.DefaultExports;

@SpringBootApplication public class VarnishDemoAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(VarnishDemoAppApplication.class, args);
    }

    @Bean
    public ServletRegistrationBean prometheusServlet() {
        ServletRegistrationBean bean = new ServletRegistrationBean(new MetricsServlet(), "/metrics");
        bean.setLoadOnStartup(1);

        // enables metrics under http://localhost:2222/metrics
        // https://github.com/prometheus/client_java#included-collectors
        DefaultExports.initialize();

        return bean;
    }

}
