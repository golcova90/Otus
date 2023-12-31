﻿
&НаСервереБезКонтекста
Функция ТестТокенаНаСервере()
	
	Результат = Неопределено;
     
    АдресURL = СтрШаблон("https://api.telegram.org/bot%1/getMe", Константы.Токен.Получить());
     
    Попытка
        Результат = КоннекторHTTP.GetJson(АдресURL);    
    Исключение
        Результат = ОписаниеОшибки();
    КонецПопытки;
     
    Возврат Результат; 
    
КонецФункции

&НаКлиенте
Процедура ТестТокена(Команда)
	РезультатТеста = ТестТокенаНаСервере();
     
    Если НЕ ТипЗнч(РезультатТеста) = Тип("Соответствие") Тогда
        Журнал.ДобавитьСтроку(СтрШаблон("Тест не выполнен: %1", РезультатТеста));
        Возврат;
    КонецЕсли;
     
    ТестВыполнен = РезультатТеста["ok"];
     
    Журнал.ДобавитьСтроку(СтрШаблон("Тест выполнен: %1", ТестВыполнен));
     
    Если НЕ ТестВыполнен Тогда
        Возврат;
    КонецЕсли;
     
    Для каждого ЭлементРезультата Из РезультатТеста["result"] Цикл
        СтрокаРезультата = СтрШаблон("%1 : %2", ЭлементРезультата.Ключ, ЭлементРезультата.Значение);
        Журнал.ДобавитьСтроку(СтрокаРезультата);
    КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	Журнал.ДобавитьСтроку(Символы.ПС);
     
    РезультатОбновления = ОбновитьНаСервере();
     
    Если НЕ ТипЗнч(РезультатОбновления) = Тип("Соответствие") Тогда
        Журнал.ДобавитьСтроку(СтрШаблон("Обновление не выполнено: %1", РезультатОбновления));
        Возврат;
    КонецЕсли;
     
    ОбновлениеВыполнено = РезультатОбновления["ok"];
     
    Журнал.ДобавитьСтроку(СтрШаблон("Обновление выполнено: %1", ОбновлениеВыполнено));
     
    Если НЕ ОбновлениеВыполнено Тогда
        Возврат;
    КонецЕсли;
     
    МассивОбновлений = РезультатОбновления["result"];
    Для каждого Обновление Из МассивОбновлений Цикл
        Журнал.ДобавитьСтроку(СтрШаблон("%1%2", Символы.ПС, " -***- "));
        ОбработатьОбновление(Обновление);
    КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ОбновитьНаСервере()
     
    РезультатОбновления = Неопределено;
     
    АдресURL = СтрШаблон("https://api.telegram.org/bot%1/getUpdates", Константы.Токен.Получить());
     
    ПараметрыЗапроса = Новый Структура;
    ПараметрыЗапроса.Вставить("offset", 0); // Идентификатор возвращаемого обновления — каждое обновление имеет свой числовой идентификатор «update_id»
	// могуть быть еще следующие параметры
	//ПараметрыЗапроса.Вставить("limit", 0); // Ограничивает количество получаемых обновлений. Принимаются значения от 1 до 100
	//ПараметрыЗапроса.Вставить("timeout", 0); // Тайм-аут в секундах для длительного опроса
	//ПараметрыЗапроса.Вставить("allowed_updates", 0); // Задается список типов обновлений, которые должен получать бот
     
    Попытка
        РезультатОбновления = КоннекторHTTP.GetJson(АдресURL, ПараметрыЗапроса);    
    Исключение
        РезультатОбновления = ОписаниеОшибки();
    КонецПопытки;
     
    Возврат РезультатОбновления;
     
КонецФункции
 
&НаКлиенте
Процедура ОбработатьОбновление(Обновление)
 
    Для каждого ЭлементОбновления Из Обновление Цикл
         
        Ключ        = ЭлементОбновления.Ключ;
        Значение    = ЭлементОбновления.Значение;
         
        Если ТипЗнч(Значение) = Тип("Соответствие") Тогда
            Журнал.ДобавитьСтроку(СтрШаблон("%1%2", Символы.ПС, Ключ));
            ОбработатьОбновление(Значение);
        Иначе
            Журнал.ДобавитьСтроку(СтрШаблон("%1 : %2", Ключ, Значение));
        КонецЕсли;
         
    КонецЦикла;
 
КонецПроцедуры

&НаКлиенте
Процедура ЭхоОтвет(Команда)
	
	ЭхоОтветНаСервере();
	
КонецПроцедуры


&НаСервере
Процедура ЭхоОтветНаСервере()
     
    Токен =  Константы.Токен.Получить();
    АдресURL = СтрШаблон("https://api.telegram.org/bot%1/getUpdates", Токен);
     
    НомерПоследнегоОбновления = Константы.НомерПоследнегоОбновления.Получить(); 
    СмещениеНомераОбновления  = НомерПоследнегоОбновления + 1;
     
    ПараметрыЗапроса = Новый Структура;
    ПараметрыЗапроса.Вставить("offset", Формат(СмещениеНомераОбновления, "ЧГ=0"));
     
    РезультатОбновления = Неопределено;
    Попытка
        РезультатОбновления = КоннекторHTTP.GetJson(АдресURL, ПараметрыЗапроса);    
    Исключение
        Журнал.ДобавитьСтроку(ОписаниеОшибки());
        Возврат;
    КонецПопытки;
     
    ОбновлениеВыполнено = РезультатОбновления["ok"];
    Если НЕ ОбновлениеВыполнено Тогда
        Журнал.ДобавитьСтроку(СтрШаблон("Ошибка: %1 - %2", РезультатОбновления["error_code"], РезультатОбновления["description"]));
        Возврат;
    КонецЕсли;
     
    МассивОбновлений = РезультатОбновления["result"];
    Если МассивОбновлений.Количество() = 0 Тогда
        Журнал.ДобавитьСтроку("Нет сообщений.");
        Возврат;
    КонецЕсли;
     
    Для каждого Обновление Из МассивОбновлений Цикл
         
        ИдентификаторОбновления = Обновление["update_id"];
         
        Сообщение = Обновление.Получить("message");
         
        ИдентификаторСообщения  = Сообщение.Получить("message_id");
        ТектСообщения           = Сообщение.Получить("text");
        ДатаСообщения           = Сообщение.Получить("date");
         
        ОтправительСообщения    = Сообщение.Получить("from");
        ИмяПользователя         = ОтправительСообщения.Получить("username");
         
        Чат                     = Сообщение.Получить("chat");
        ИдентификаторЧата       = Чат.Получить("id");
         
        АдресURL = СтрШаблон("https://api.telegram.org/bot%1/sendMessage", Токен);
         
        ПараметрыЗапроса = Новый Структура;
        ПараметрыЗапроса.Вставить("chat_id",    Формат(ИдентификаторЧата, "ЧГ=0"));
        ПараметрыЗапроса.Вставить("text",       "что угодно напиши");
         
        РезультатОтправки = Неопределено;
        Попытка
            РезультатОтправки = КоннекторHTTP.GetJson(АдресURL, ПараметрыЗапроса);  
        Исключение
            Журнал.ДобавитьСтроку(ОписаниеОшибки());
            Продолжить;
        КонецПопытки;
         
        СообщениеОтправлено = РезультатОтправки["ok"];
        Если СообщениеОтправлено Тогда
             
            Журнал.ДобавитьСтроку(СтрШаблон("Сообщение: %1 - Отправлено пользователю: %2", ТектСообщения, ИмяПользователя));
            НомерПоследнегоОбновления = ИдентификаторОбновления;
             
        Иначе
            Журнал.ДобавитьСтроку(СтрШаблон("Ошибка: %1 - %2", РезультатОтправки["error_code"], РезультатОтправки["description"]));
        КонецЕсли;
         
    КонецЦикла;
     
    Если НомерПоследнегоОбновления >= СмещениеНомераОбновления Тогда
        Константы.НомерПоследнегоОбновления.Установить(НомерПоследнегоОбновления);      
    КонецЕсли;
     
КонецПроцедуры

