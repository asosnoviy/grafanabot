#Использовать oint

&Деталька("TELEGRAMM.TOKEN")
Перем Токен;

&Пластилин
Перем РазрешенныеПользователи;

&Пластилин
Перем РазрешенныеГруппы;

&Пластилин
Перем ГрафанаОпрашиватель;

Перем КлавиатураОбщая;
Перем МассивКлавиатуры;

&Соответствие
Перем ПомнюДашборды;

&Соответствие
Перем ОтправленныеСообщения;

&Число
Перем Смещение;

&Желудь
Процедура ПриСозданииОбъекта()

КонецПроцедуры

&ФинальныйШтрих
Процедура ПослеСозданииОбъекта() Экспорт
 
	МассивКлавиатуры = МассивКлавиатуры();
	КлавиатураОбщая = OPI_Telegram.СформироватьКлавиатуруПоМассивуКнопок(МассивКлавиатуры, Ложь, Истина);

КонецПроцедуры

Функция МассивКлавиатуры()
	Возврат ГрафанаОпрашиватель.ИменаПлейлистов(); 
КонецФункции

Процедура Запустить() Экспорт
	Сообщить("Запущен");
	
	Пока Истина Цикл
	
		Ответ     = OPI_Telegram.ПолучитьОбновления(Токен, 30, Смещение);
		Результат = Ответ["result"];

		Если Результат = Неопределено ИЛИ Результат.ВГраница() = -1 Тогда
			Продолжить;
		Иначе
			Сообщение = Результат[Результат.ВГраница()];
			Смещение  = Сообщение["update_id"] + 1;
		КонецЕсли;

		ОбработатьРезультат(Сообщение);

	КонецЦикла;

КонецПроцедуры

Процедура ОбработатьРезультат(Сообщение)

	Если Сообщение.Получить("message") <> Неопределено Тогда
		ПользовательИД = Сообщение["message"]["from"]["id"];
		ЧатИД = Сообщение["message"]["chat"]["id"];
	ИначеЕсли  Сообщение.Получить("callback_query") <> Неопределено Тогда
		ПользовательИД = Сообщение["callback_query"]["from"]["id"];
		ЧатИД = Сообщение["callback_query"]["message"]["chat"]["id"];
	КонецЕсли;

	Сообщить(ЧатИД);
	Если РазрешенныеПользователи[ПользовательИД] = Неопределено 
			И РазрешенныеГруппы[ЧатИД] = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ОтправленныеСообщения[ЧатИД] = Неопределено Тогда
		ОтправленныеСообщения.Вставить(ЧатИД, Новый Массив());
	КонецЕсли;

	ПоказатьКлавиатуру(Сообщение);

	Если НЕ НадоИдтиДальше(Сообщение) Тогда
		Возврат;
	КонецЕсли;

	ПоказатьСписокДашбордов(Сообщение);

	ОтправитьДашборт(Сообщение);

КонецПроцедуры

Функция НадоИдтиДальше(Сообщение)

	Возврат Истина;
КонецФункции
	
Процедура ПоказатьСписокДашбордов(Сообщение)

	ЭтоСообщение = Сообщение["message"] <> Неопределено;

	Если Не ЭтоСообщение Тогда
		Возврат;
	КонецЕсли;

	ТекстСообщения = Сообщение["message"]["text"];

	Если МассивКлавиатуры.Найти(ТекстСообщения) = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Дашборды = ГрафанаОпрашиватель.ДашбордыПлейлиста(ТекстСообщения);
	
	СписокДашбордов = Новый Массив;
	Для Каждого Дашборд Из Дашборды Цикл

		ОписанеДашборда = ГрафанаОпрашиватель.ОписаниеДашборда(Дашборд["value"]);
		title = ОписанеДашборда["dashboard"]["title"];

		Если title = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		СписокДашбордов.Добавить(title);
		ПомнюДашборды.Вставить(title, ОписанеДашборда);
	КонецЦикла;

	КлавиатураДашборда = OPI_Telegram.СформироватьКлавиатуруПоМассивуКнопок(СписокДашбордов, Истина, Истина);

	ЧатИД = Сообщение["message"]["chat"]["id"];

	ДашбордСообщение = OPI_Telegram.ОтправитьТекстовоеСообщение(Токен, ЧатИД, ТекстСообщения, КлавиатураДашборда);
	OPI_Telegram.УдалитьСообщение(Токен, ЧатИД, Сообщение["message"]["message_id"]);
	ОтправленныеСообщения[ЧатИД].Добавить(ДашбордСообщение["result"]["message_id"]);
	
КонецПроцедуры

Процедура ОтправитьДашборт(Сообщение)

	ЭтоКалбек = Сообщение["callback_query"] <> Неопределено;

	Если НЕ ЭтоКалбек Тогда
		Возврат;
	КонецЕсли;
	
	ИмяДашборда = Сообщение["callback_query"]["data"];
	Дашборд = ПомнюДашборды[ИмяДашборда];

	Если Дашборд  = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЧатИД = Сообщение["callback_query"]["message"]["chat"]["id"];

	СообщениеОжидайте = OPI_Telegram.ОтправитьТекстовоеСообщение(Токен, ЧатИД, "Ожидайте");  
	
	ДДКартинки = ГрафанаОпрашиватель.КартинкаДашборда(Дашборд["meta"]["url"]);

	OPI_Telegram.УдалитьСообщение(Токен, ЧатИД, СообщениеОжидайте["result"]["message_id"]);
	
	OPI_Telegram.ОтправитьКартинку(Токен, ЧатИД, ИмяДашборда, ДДКартинки, КлавиатураОбщая);

	ОтправленныеСообщения[ЧатИД].Добавить(Сообщение["callback_query"]["message"]["message_id"]);
	
	Для каждого ОтправленноеСообщение Из ОтправленныеСообщения[ЧатИД] Цикл
		OPI_Telegram.УдалитьСообщение(Токен, ЧатИД, ОтправленноеСообщение);
	КонецЦикла;

КонецПроцедуры

Процедура ПоказатьКлавиатуру(Сообщение)
	
	Попытка
		ЭтоСтарт = Нрег(Сообщение["message"]["text"]) = Нрег("/start");
	Исключение
		ЭтоСтарт = Ложь;
	КонецПопытки;

	Если НЕ ЭтоСтарт Тогда
		Возврат;
	КонецЕсли;

	ЧатИД = Сообщение["message"]["chat"]["id"];

	OPI_Telegram.ОтправитьТекстовоеСообщение(Токен, ЧатИД, "Список плейлистов доступен в панели кнопок", КлавиатураОбщая);

КонецПроцедуры
