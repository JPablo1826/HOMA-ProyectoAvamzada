import { Injectable } from "@angular/core";
import { environment } from "@environments/environment";

@Injectable({
  providedIn: "root",
})
export class ConfigService {
  private apiUrl: string = "";

  constructor() {
    // Leer de variables de ambiente del navegador
    const envApiUrl = (window as any).__APP_CONFIG__?.API_URL;
    
    // Si no hay variable de ambiente en runtime, usar environment de Angular
    this.apiUrl = envApiUrl || environment.apiUrl;
    
    console.log("[ConfigService] API URL: ", this.apiUrl);
  }

  getApiUrl(): string {
    return this.apiUrl;
  }
}
