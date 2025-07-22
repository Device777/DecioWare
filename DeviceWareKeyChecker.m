
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void showKeyPrompt() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Device Ware"
                                                                       message:@"Insira sua chave para ativar"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"DEVICEWARE-XXXXXX";
        }];

        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Ativar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            if (key.length == 0) exit(0);

            NSURL *url = [NSURL URLWithString:@"https://devicewareapi.onrender.com/validate_key"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            NSString *postStr = [NSString stringWithFormat:@"key=%@", key];
            [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
            [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

            NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error || !data) {
                        exit(0);
                    }

                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (![json[@"status"] isEqualToString:@"ok"]) {
                        exit(0);
                    }
                }];
            [task resume];
        }];

        [alert addAction:confirm];

        UIWindow *keyWindow = UIApplication.sharedApplication.windows.firstObject;
        [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
static void initialize() {
    showKeyPrompt();
}
