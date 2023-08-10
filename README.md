![Cover](https://github.com/DenDmitriev/grabshot/assets/65191747/a52c4252-d0a7-47d1-8a80-87c8ea5ce7f7)

# GrabShot
Приложение macOS для создания серии скриншотов из видео файла.

https://github.com/DenDmitriev/grabshot/assets/65191747/61467b2b-11c0-497f-8b7a-ac36be76bea2

## Содержание
- [Начало](#начало)
- [Задачи](#задачи)
- [Обзор](#обзор)
  - [Возможности](#возможности)
     - [Импорт видео](#импорт-видео)
     - [Захват изображений](#захват-изображений)
     - [Результат](#результат)
       - [Кадры](#кадры)
       - [Штрихкод](#штрихкод)
  - [Настройки](#настройки)
       - [Настройки захвата](#настройки-захвата)
       - [Настройки штрихкода](#настройки-штрихкода)
- [Реализация](#реализация)
  - [Интерфейс](#интерфейс)
  - [Захват](#захват)
  - [Создание штрихкода](#создание-штрихкода)
- [ToDo](#todo)


# Начало
В работе медиа, при планировании рекламных роликов и фильмов, требуется создание мудборд презентаций. Презентации состоят обычно из кадров других похожих работ. Чтоб облегчить поиск и время на отсмотр вдохновляющих материалов, я решил написать приложение которое автоматизирует этот процесс. Исходные навыки дала мне школа [GeekBrains](https://gb.ru), где я учюсь на разработчика iOS приложений. Бибилотеки реализации приложений на iOS и macOS одни и теже, поэтому я решил написать такую утилиту.

# Задачи
- [x] Импорт серии видео файлов в приложение
- [x] Захват изображений с заданным интервалом
- [x] Создание штрихкода цвета для видео
- [x] Сохранение файлов захвата на диск
- [x] Настройки для параметров захвата

# Обзор
## Возможности
### Импорт видео
На стадии задумки я хотел чтоб пользователь мог загрзить сразу серию видео файлов и самаы быстрым и понятным способом оказался - Drag&Drop. Поэтому первое окно при запуске - 
это поле куда пользователь может перетащить видео файлы. 

<img width="712" alt="Drop" src="https://github.com/DenDmitriev/grabshot/assets/65191747/a0ee590b-201f-4da0-bfeb-c4bb1c23dea4">

Так же есть классический способ выбрать файл через панель навигации приложения сверху "Файл -> Выбрать Видео" или горячие клавиши ⌘ + O.

<img width="220" alt="Import" src="https://github.com/DenDmitriev/grabshot/assets/65191747/63954553-960a-43bc-8793-0f82703190b0">

На панели навигации приложения есть элемент с вкладками, чтоб пользователь мог переключаться между рабочами окнами

### Захват изображений
После импорта видео файла, приложение автоматически переключается на вкладку захвата изображений. Здесь таблица, где мы видим выбранное видео с информацией расположения файла в виде ссылки, длительность, колличество кадров захвата на выходе при текущем интервале внизу и шкала прогресса. Ниже настроек есть поле для цветового штрихкода, которое будет динамически рисоваться с каждым кадром захвата. [Barcode](https://thefilmstage.com/movie-barcode-an-entire-feature-film-in-one-image/) - это цветовая палитра кадров в фильме, она отражает цветовой характер использованных цветов и оттенков в произведении. На поле штрихкода есть кнопка для просмотра штрихкода. Последняя зона - это общий прогресс очереди захвата с кнопками запуска/остановки и отмены.

<img width="712" alt="GrabOne" src="https://github.com/DenDmitriev/grabshot/assets/65191747/c1875f0b-5bc2-46a9-a6a2-68344f6dc42f">

При запуске процесса по кнопке Старт, начинается [захват](#захват) кадров. Над школой прогресса есть лог описание что происходит в данный момент, какой текущий кадр и сколько их всего.

<img width="712" alt="GrabProcess" src="https://github.com/DenDmitriev/grabshot/assets/65191747/ec82df88-2281-48b6-ae7d-54f792b35292">

И конечно есть возможность сделать скриншоты для всех импортированных файлов. Прогресс в таблице показывает состояние каждого, а общий всей очереди.

<img width="712" alt="GrabQueue" src="https://github.com/DenDmitriev/grabshot/assets/65191747/979f63ed-b798-41f3-ac5c-2eaf97d38ecc">

### Результат

#### Кадры
Получившиеся кадры в процессе сохраняются на диск в автоматически созданную папку с тем же названием что и видео файл. Местоположение папки то же что и файл. Название кадров - это название видео файла с суффиксом таймкода.  

<img width="1032" alt="Output" src="https://github.com/DenDmitriev/grabshot/assets/65191747/e37c97a6-8c4c-4daf-9e03-f64dc378e3db">

#### Штрихкод
Получившийся цветовой штрихкод можно посомтреть по кнопке на его поле. Файл сохраняется тоже в папку с кадрами.

<img width="712" alt="StripPreview" src="https://github.com/DenDmitriev/grabshot/assets/65191747/f9ace501-0ec2-40ba-82cc-0b885420cac8">

Ниже приведены несколько штрихкодов из разных фильмов.

 - [Сериал Разделение](https://www.kinopoisk.ru/series/1343318/)
  ![Severance S01E01 1080p rus LostFilm TVStrip](https://github.com/DenDmitriev/grabshot/assets/65191747/a69d156f-1c5a-4e5e-b4c0-0b4ebfbd58ef)

 - [Бесподобный мистер Фокс ](https://www.kinopoisk.ru/film/86621/?utm_referrer=www.google.com)
![Fantastic Mr Fox 2009 1080p BluRay DTS Rus Eng HDCLUBStrip](https://github.com/DenDmitriev/grabshot/assets/65191747/f5a92065-6a33-40f4-ae3b-0d76d43c1c2f)

 - [Фильм Тар](https://www.kinopoisk.ru/film/4511218/)
  ![Tár (2022) BDRip 1080p-V_odne_riloStrip](https://github.com/DenDmitriev/grabshot/assets/65191747/836774c2-d841-48e8-9eea-cb1b05a5ec18)


## Настройки
Работу приложения можно настроить. Запуск окна для этого лежит в интуитивном месте - в верхней панели системы по нажатию на назвние программы или комюинацией ⌘ + ,. 

<img width="363" alt="SettingsNavigation" src="https://github.com/DenDmitriev/grabshot/assets/65191747/2621377a-7cfc-40fc-a3f7-d7de4ac22fbf">

Окно настроек делится на две вкладки.

### Настройки захвата
Здесь есть ползунок для выбора степени сжатия JPG ихображений. И переключатель открытия папки с получишимися изображениями в финале процесса захвата.

<img width="721" alt="GrabSettings" src="https://github.com/DenDmitriev/grabshot/assets/65191747/e9852f33-9762-4332-886b-ec74a0b3d87b">

### Настройки штрихкода
Штрихкод нужен для разных задач и какой он должен быть - должен определит пользователь. На каждом кадре определяется [средний цвет](#штрихкод) или цвета, их колличество можно выбрать. Разрешение конечного изображения может понадобится большим или наоборот маленьким, поэтому есть поля для размера в пикселях.

<img width="721" alt="StripSettings" src="https://github.com/DenDmitriev/grabshot/assets/65191747/7071504d-94cc-4d28-8fbb-19edee3afb82">

<img width="145" alt="Colors" src="https://github.com/DenDmitriev/grabshot/assets/65191747/11ed2a66-ecb8-48d5-8616-0c563c68bef9">

# Реализация
Использованные ресурсы:
- [SwiftUI](#интерфейс)
- [AVFoundation](#захват)
- [FFmpeg](#захват)
- [OperationQueue](#очередь-операций)
- [Core Image](#создание-штрихкода)

## Интерфейс
Интерфейс я решил написать на SwiftUI. Причины этого решения: 
 - Хотелось закрепить знания этого фреймворка, которые я получил в IT школе
 - Приложение не сложное, поэтому проблемы нового фреймворка по отношению не должны были возникнуть
 - Синтаксис фреймворка одинаковый для мобильных приложений и для macOS
 - В SwiftUI есть предикаты, которые делают код реактивным, что уменбшает колличество кода
 - Научится работать с предикатами на практике
 
## Захват
Я провел поиск подходящего мультимедиа фремворка и рассматривал следующие: 
- [AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [VLCKit](https://github.com/videolan/vlckit)
- [FFmpeg](https://ffmpeg.org)

Как правило весь видео материал кино и сериалов в сети формата [MKV](https://ru.wikipedia.org/wiki/Matroska), а встреонный AVFoundation его не поддерживает и сразу отпал. Ниже код, под реализацию зазхвата этим фреймворком:
https://github.com/DenDmitriev/grabshot/blob/f98c89b1fa4ed00090236d8991ee06e54beb04d1/GrabShot/Service/VideoService.swift#L54-L75

VLCKit поддерживает MKV имеет простую документацию, написан на Objective-C. Имопртируется Pod или Package Manager. Но возникла проблема в получении серии скриншотов, они дублировались по неизвестным причинам. То есть таймкод новый в функции, а библиотека выдает прошлый кадр.

Решил попробовать FFmpeg, тут сложнее, потому что общение с фреймфорком требуется через командую строку, но это возможно. На этот раз результат был всегда точный.
Есть документация и примеры кода на Stack Overflow. Ниже функция захвата через Process().
https://github.com/DenDmitriev/grabshot/blob/f98c89b1fa4ed00090236d8991ee06e54beb04d1/GrabShot/Service/VideoService.swift#L20-L52

## Очередь операций
Серия операций захвата создается через [OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue)
https://github.com/DenDmitriev/grabshot/blob/0db917ad3e415d68932b05e28579872dc6e7d3ea/GrabShot/Core/GrabOperation/GrabOperation.swift#L21
https://github.com/DenDmitriev/grabshot/blob/0db917ad3e415d68932b05e28579872dc6e7d3ea/GrabShot/Core/GrabOperation/GrabOperation.swift#L30-L31
https://github.com/DenDmitriev/grabshot/blob/0db917ad3e415d68932b05e28579872dc6e7d3ea/GrabShot/Core/GrabOperation/GrabOperation.swift#L38-L46
https://github.com/DenDmitriev/grabshot/blob/0db917ad3e415d68932b05e28579872dc6e7d3ea/GrabShot/Core/GrabOperation/GrabOperation.swift#L61-L68
https://github.com/DenDmitriev/grabshot/blob/0db917ad3e415d68932b05e28579872dc6e7d3ea/GrabShot/Core/GrabOperation/GrabOperation.swift#L70-L100

## Создание штрихкода
Принцип создания не сложный. Опишу его.
Цветовая палитра одного кадра - это набор нескольких прямоугольников с усредненными цветам кадра выстроенных по горизонтали. Например она может выглядеть так.

<img width="220" alt="ColotPalete" src="https://github.com/DenDmitriev/grabshot/assets/65191747/394750a6-af01-4876-b861-a3567565180b">

Если взять несколько таких палитр, выстроить их по горизонтали, то получится очень длинная полоса с цветовыми прямоугольниками. Далее надо их сжать до ширины экрана, чтоб видеть все сруз и вот получится цветовой штрихкод.
Для создания такого изображения я использовал [Core Image](https://developer.apple.com/documentation/coreimage). Функция высчитывания средних цвета изображения
https://github.com/DenDmitriev/grabshot/blob/f98c89b1fa4ed00090236d8991ee06e54beb04d1/GrabShot/Helper/NSImageExtension.swift#L29-L56

Получив координаты цвета в виде Color, я создаю привычное SwiftUI view через стек прямоугольников заполненых цветом. Которые пополняются по мере обноления модели Video. 
https://github.com/DenDmitriev/grabshot/blob/f98c89b1fa4ed00090236d8991ee06e54beb04d1/GrabShot/View/Elements/StripView.swift#L10-L27

Сохранить получившееся вью в изорбражение можно используя [ImageRenderer](https://developer.apple.com/documentation/swiftui/imagerenderer)
https://github.com/DenDmitriev/grabshot/blob/f98c89b1fa4ed00090236d8991ee06e54beb04d1/GrabShot/Model/StripModel.swift#L18-L38


# ToDo
- [ ] Перенести создание скриншотов для поддерживаемых форматов на встроенную библиотеку AVFoundation