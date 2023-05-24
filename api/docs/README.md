# API Documentation

## Endpoints

### User

**URL** : `/user/`

**Method** : `POST`

**Data Parameters** :

```json
{
"username": "[string]",
"password": "[string]"
}
```


**Success Response**

- **Code** : `201 CREATED`
- **Content** : 
```json
{
"id": "[integer]",
"username": "[string]",
"password": "[string]",
"lat": "[float]",
"lon": "[float]"
}
```


**Error Response**

- **Code** : `400 BAD REQUEST`

---

### User with ID

**URL** : `/user/<id>/`

**Method** : `GET` | `PATCH` | `DELETE`

**URL Parameters** : `id=[integer]` where `id` is the ID of the user on the server.

**Success Response**

- **Code** : `200 OK`
- **Content** : 
```json
{
"id": "[integer]",
"username": "[string]",
"password": "[string]",
"lat": "[float]",
"lon": "[float]"
}
```


**Error Response**

- **Code** : `400 BAD REQUEST` 
- **Content** : `{ "message": "ID required" }` OR `{ "message": "ID must be a number" }`

- **Code** : `404 NOT FOUND`
- **Content** : `{ "message": "User not found" }`

**Note for PATCH**

For `PATCH` method, you may include any of the following parameters in your request:

```json
{
"username": "[string]",
"password": "[string]",
"lat": "[float]",
"lon": "[float]"
}
``` 
