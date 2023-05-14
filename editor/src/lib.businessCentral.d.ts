/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
declare interface Environment {
  /**
   * The name of the user that is logged into the Dynamics 365 Business Central service.
   */
  UserName: string;
  /**
   * The name of the company that the current user is using on the Dynamics 365 Business Central service.
   */
  CompanyName: string;
  /**
   * An integer indicating the type of device that the control add-in is being rendered on. Possible values:
   * * 0 – Desktop client, either Dynamics NAV Client connected to Business Central or Business Central Web client.
   * * 1 – Business Central tablet client.
   * * 2 – Business Central phone client.
   */
  DeviceCategory: 0 | 1 | 2;
  /**
   * A boolean indicating whether the client is currently busy. The client could, for example, be busy performing an asynchronous call to the server.
   */
  Busy: boolean;
  /**
   * A function that is called when the Busy state of the client has changed.
   */
  OnBusyChanged: (busy: boolean) => void;
  /**
   * An integer indicating the type of device that the control add-in is being rendered on. Possible values:
   * * 0 – Dynamics NAV Client connected to Business Central.
   * * 1 – Business Central Web client, Business Central tablet client, or Business Central phone client in a browser.
   * * 2 – Business Central Mobile App.
   * * 3 - Microsoft Office add-in.
   */
  Platform: 0 | 1 | 2 | 3;
  /**
   * An integer indicating the underlying platform that the control add-in is being rendered on. Possible values:
   * * 0 - Mouse.
   * * 1 - Touch.
   */
  UserInteractionMode: 0 | 1;
}
declare namespace Microsoft.Dynamics {
  class NAV {
    /**
     * Gets the URL for an image resource specified in the control add-in manifest.
     * The image resource is stored in the database as part of the .zip file for the
     * control add-in and is exposed to the control add-in script running on the
     * Business Central client using the URL that this method returns.
     * @param resourceName A string that contains the name of the image resource to get a URL for. The image name is the name that is used in the control add-in manifest to reference the image
     */
    static GetImageResource(resourceName: string): string;
    /**
     * Invokes an AL trigger on the Dynamics 365 Business Central service on the page that contains the control add-in
     * @param methodName A string that contains the name of the AL trigger to invoke. This must be the name of the specified event using the [ApplicationVisible] attribute that defines the control add-in.
     * @param args An array that contains the arguments to pass to the AL trigger. Note that the arguments must be supplied in an array even when the trigger only takes one argument.
     * @param skipIfBusy A value to indicate whether to invoke the extensibility method if the client is busy. This parameter is optional and the default value is false
     * @param callback A function that is called when the extensibility method has finished execution on the server. This parameter is optional
     */
    static InvokeExtensibilityMethod(
      methodName: string,
      args?: any[],
      skipIfBusy?: boolean,
      callback?: () => void
    ): void;
    /**
     * Gets information about the environment that the control add-in is using.
     */
    static GetEnvironment(): Environment;
    /**
     * Opens a new browser window which navigates to the specified URL.
     * The benefit of using this function instead of using the native browser function,
     * is that this function also works when using the control add-in in an app,
     * for example on a phone. If you are using the native browser function in an app,
     * the behavior varies between the different platforms (Windows, iOS, Android)
     * @param url the URL for the new browser window to navigate to.
     */
    static OpenWindow(url: string): void;
  }
}
