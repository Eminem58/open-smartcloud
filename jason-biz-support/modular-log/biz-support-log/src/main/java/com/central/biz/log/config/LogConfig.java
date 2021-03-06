package com.central.biz.log.config;

import com.central.biz.log.core.db.CommonLogInitializer;
import com.central.biz.log.core.db.TraceLogInitializer;
import com.central.biz.log.core.listener.LogMessageListener;
import com.central.biz.log.modular.controller.LogController;
import com.central.biz.log.modular.provider.LogServiceProvider;
import com.central.biz.log.modular.service.CommonLogService;
import com.central.biz.log.modular.service.TraceLogService;
import com.central.logger.chain.aop.ChainOnControllerAop;
import com.central.logger.config.DefaultLogConfig;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 日志服务的自动配置
 */
@Configuration
public class LogConfig extends DefaultLogConfig {

    /**
     * 数据库初始化
     */
    @Bean
    public CommonLogInitializer commonLogInitializer() {
        return new CommonLogInitializer();
    }

    @Bean
    public TraceLogInitializer traceLogInitializer() {
        return new TraceLogInitializer();
    }

    /**
     * 日志的消息监听器
     */
    @Bean
    public LogMessageListener logMessageListener() {
        return new LogMessageListener();
    }

    /**
     * 控制器
     */
    @Bean
    public LogController logController() {
        return new LogController();
    }

    /**
     * service服务
     */
    @Bean
    public CommonLogService commonLogService() {
        return new CommonLogService();
    }

    @Bean
    public TraceLogService traceLogService() {
        return new TraceLogService();
    }

    /**
     * 服务提供者
     */
    @Bean
    public LogServiceProvider logServiceProvider() {
        return new LogServiceProvider();
    }

    /**
     * 日志拦截器 controller
     */
    @Bean
    public ChainOnControllerAop chainOnControllerAop() {
        return new ChainOnControllerAop();
    }
}
