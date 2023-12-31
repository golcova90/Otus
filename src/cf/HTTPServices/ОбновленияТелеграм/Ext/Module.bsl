﻿
Функция ВебхукPOST(Запрос)
	Обновление = КоннекторHTTP.JsonВОбъект(Запрос.ПолучитьТелоКакСтроку());
	 
	Сообщение = Обновление.Получить("message");
	
	Если Сообщение = Неопределено Тогда
		Сообщение = Обновление.Получить("edited_message");
	КонецЕсли;
	 
	ТекстСообщения      = Сообщение.Получить("text");
	Чат                 = Сообщение.Получить("chat");
	ИдентификаторЧата   = Чат.Получить("id");
	
	БлокFrom = Сообщение.Получить("from");
	
	Если БлокFrom <> Неопределено Тогда	
		ИмяСобеседника = БлокFrom.Получить("first_name");
	Иначе
		ИмяСобеседника = "Друг"; 
	КонецЕсли;
	 
	АдресURL = СтрШаблон("https://api.telegram.org/bot%1/sendMessage", Константы.Токен.Получить());
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("chat_id", Формат(ИдентификаторЧата, "ЧГ=0"));
	
	КомандыБота = Новый Соответствие;
	КомандыБота.Вставить("/help", СтрШаблон("Добро пожаловать в Любочкин Бот! Я умею выполнять разные команды. Вот некоторые из них: %1/BD_parent %1/BD_child %1/getCompliment %1/help ", Символы.ПС));
	КомандыБота.Вставить("/start", СтрШаблон("Добро пожаловать в Любочкин Бот! Я умею выполнять разные команды. Вот некоторые из них: %1/BD_parent %1/BD_child %1/getCompliment %1/help ", Символы.ПС));
	КомандыБота.Вставить("/BD_parent",  СтрШаблон("День рождения мамы: 15 ноября %1День рождения папы: 27 мая", Символы.ПС));
	КомандыБота.Вставить("/BD_child", СтрШаблон("День рождения Любы: 24 марта 2018 года %1День рождения Саши: 5 ноября 2021 года", Символы.ПС));
	КомандыБота.Вставить("/getCompliment", СтрШаблон("%1, ты самый лучший человек на свете!!! И я тебя люблю. Мне очень повезло что ты, %1, есть в моей жизни!", ИмяСобеседника));
	
	ТекстОтвета = КомандыБота.Получить(ТекстСообщения);
	
	Если ТекстОтвета <> Неопределено Тогда
		ПараметрыЗапроса.Вставить("text", ТекстОтвета);
	Иначе
		ПараметрыЗапроса.Вставить("text", "Люба лучше всех!");	
	КонецЕсли;

		 
	РезультатОтправки = Неопределено;
	Попытка
	    РезультатОтправки = КоннекторHTTP.GetJson(АдресURL, ПараметрыЗапроса);  
	Исключение
	    ЗаписьЖурналаРегистрации("ОбновленияТелеграм.ВебхукPOST", УровеньЖурналаРегистрации.Ошибка, , , ОписаниеОшибки());
	    Возврат Новый HTTPСервисОтвет(503);
	КонецПопытки;
     
    Возврат Новый HTTPСервисОтвет(200);
КонецФункции
