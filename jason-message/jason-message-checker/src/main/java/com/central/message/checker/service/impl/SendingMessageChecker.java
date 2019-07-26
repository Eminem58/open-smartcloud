package com.central.message.checker.service.impl;

import com.central.core.model.page.PageResult;
import com.central.message.api.model.ReliableMessage;
import com.central.message.checker.consumer.MessageServiceConsumer;
import com.central.message.checker.service.AbstractMessageChecker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Calendar;
import java.util.Map;

/**
 * 处理状态为“发送中”但超时没有被成功消费确认的消息
 */
@Service
public class SendingMessageChecker extends AbstractMessageChecker {
    //private static final Logger logger = LoggerFactory.getLogger(SendingMessageChecker.class);
    private Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private MessageServiceConsumer messageServiceConsumer;

    @Resource(name = "sendTimeInterval")
    private Map<Integer, Integer> notifyParam;

    @Override
    protected void processMessage(Map<String, ReliableMessage> messageMap) {

        // 单条消息处理
        for (Map.Entry<String, ReliableMessage> entry : messageMap.entrySet()) {
            ReliableMessage message = entry.getValue();
            try {
                // 判断发送次数
                int maxTimes = notifyParam.size();

                // 如果超过最大发送次数直接退出
                if (message.getMessageSendTimes() > maxTimes) {

                    // 标记为死亡
                    messageServiceConsumer.setMessageToAreadlyDead(message.getMessageId());
                    continue;
                }

                // 判断是否达到发送消息的时间间隔条件
                int reSendTimes = message.getMessageSendTimes();
                int times = notifyParam.get(reSendTimes == 0 ? 1 : reSendTimes);//间隔几分钟
                long currentTimeInMillis = Calendar.getInstance().getTimeInMillis();
                long needTime = currentTimeInMillis - times * 60 * 1000;
                long hasTime = message.getLastModificationTime().getTime();

                // 判断是否达到了可以再次发送的时间条件
                if (hasTime > needTime) {
                    continue;
                }

                // 重新发送消息
                messageServiceConsumer.reSendMessage(message);
                logger.info("处理[SENDING]消息ID为[" + message.getMessageId() + "]的消息,第"+times+"次重发");
            } catch (Exception e) {
                logger.error("处理[SENDING]消息ID为[" + message.getMessageId() + "]的消息异常：", e);
            }
        }

    }

    @Override
    protected PageResult<ReliableMessage> getPageResult(Map<String, Object> params) {
        return messageServiceConsumer.listPageSendingTimeOutMessages(params);
    }

}
