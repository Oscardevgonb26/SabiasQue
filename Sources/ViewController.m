#import "ViewController.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *categoryLabel;
@property (strong, nonatomic) UITextField *categoryTextField;
@property (strong, nonatomic) UILabel *factLabel;
@property (strong, nonatomic) UIButton *searchButton;

@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) NSArray<NSString *> *categories;
@property (strong, nonatomic) NSDictionary<NSString *, NSArray<NSString *> *> *factsByCategory;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *nextIndexByCategory;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // a) 3 categorías
    self.categories = @[@"Categoría 1", @"Categoría 2", @"Categoría 3"];

    // b) y c) Datos curiosos por categoría (rota al presionar Buscar)
    self.factsByCategory = @{
        @"Categoría 1": @[
            @"¿Sabías que? La categoría 1 puede mostrar información relacionada con deportes del año 2020.",
            @"¿Sabías que? Algunos récords deportivos se definen por milésimas de segundo.",
            @"¿Sabías que? El rendimiento deportivo también depende del descanso y la nutrición."
        ],
        @"Categoría 2": @[
            @"¿Sabías que? La categoría 2 puede incluir datos curiosos de tecnología del año 2015.",
            @"¿Sabías que? Un sensor pequeño puede medir luz, movimiento o temperatura con gran precisión.",
            @"¿Sabías que? Optimizar una app mejora su rendimiento y puede ahorrar batería."
        ],
        @"Categoría 3": @[
            @"¿Sabías que? La categoría 3 puede mostrar información relacionada con eventos del año 2010.",
            @"¿Sabías que? El contexto histórico cambia la interpretación de un hecho según la fuente.",
            @"¿Sabías que? Comparar causas e impacto ayuda a entender mejor un evento histórico."
        ]
    };

    self.nextIndexByCategory = [NSMutableDictionary dictionary];

    [self buildUI];
    [self setupPicker];
}

- (void)buildUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"¿Sabías qué?";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:34];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.categoryLabel = [[UILabel alloc] init];
    self.categoryLabel.text = @"Categoría";
    self.categoryLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.categoryTextField = [[UITextField alloc] init];
    self.categoryTextField.placeholder = @"Selecciona una opción";
    self.categoryTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.categoryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryTextField.delegate = self;

    self.factLabel = [[UILabel alloc] init];
    self.factLabel.text = @"";
    self.factLabel.numberOfLines = 0;
    self.factLabel.font = [UIFont systemFontOfSize:16];
    self.factLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchButton setTitle:@"Buscar" forState:UIControlStateNormal];
    self.searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.searchButton.layer.borderWidth = 1.0;
    self.searchButton.layer.cornerRadius = 6.0;
    self.searchButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchButton addTarget:self action:@selector(searchTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.categoryLabel];
    [self.view addSubview:self.categoryTextField];
    [self.view addSubview:self.factLabel];
    [self.view addSubview:self.searchButton];

    UILayoutGuide *g = self.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:g.topAnchor constant:80],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:24],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-24],

        [self.categoryLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:60],
        [self.categoryLabel.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:24],

        [self.categoryTextField.topAnchor constraintEqualToAnchor:self.categoryLabel.bottomAnchor constant:8],
        [self.categoryTextField.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:24],
        [self.categoryTextField.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-24],

        [self.factLabel.topAnchor constraintEqualToAnchor:self.categoryTextField.bottomAnchor constant:16],
        [self.factLabel.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:24],
        [self.factLabel.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-24],

        [self.searchButton.topAnchor constraintEqualToAnchor:self.factLabel.bottomAnchor constant:18],
        [self.searchButton.centerXAnchor constraintEqualToAnchor:g.centerXAnchor],
        [self.searchButton.widthAnchor constraintEqualToConstant:140],
        [self.searchButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)setupPicker {
    self.picker = [[UIPickerView alloc] init];
    self.picker.delegate = self;
    self.picker.dataSource = self;

    self.categoryTextField.inputView = self.picker;

    UIToolbar *tb = [[UIToolbar alloc] init];
    [tb sizeToFit];

    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];

    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithTitle:@"Listo"
                             style:UIBarButtonItemStyleDone
                             target:self
                             action:@selector(doneTapped)];

    tb.items = @[flex, done];
    self.categoryTextField.inputAccessoryView = tb;
}

- (void)doneTapped {
    NSInteger row = [self.picker selectedRowInComponent:0];
    self.categoryTextField.text = self.categories[row];
    [self.categoryTextField resignFirstResponder];
}

- (void)searchTapped {
    NSString *cat = self.categoryTextField.text;

    if (cat.length == 0) {
        self.factLabel.text = @"Selecciona una categoría para ver un dato curioso.";
        return;
    }

    NSArray<NSString *> *facts = self.factsByCategory[cat];
    if (facts.count == 0) {
        self.factLabel.text = @"No hay información disponible para esta categoría.";
        return;
    }

    NSInteger idx = [self.nextIndexByCategory[cat] integerValue];
    self.factLabel.text = facts[idx];

    // c) Siguiente toque muestra otro dato
    idx = (idx + 1) % facts.count;
    self.nextIndexByCategory[cat] = @(idx);
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.categories.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.categories[row]; }
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.categoryTextField.text = self.categories[row];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO; // No escribir a mano, solo elegir del picker
}

@end
