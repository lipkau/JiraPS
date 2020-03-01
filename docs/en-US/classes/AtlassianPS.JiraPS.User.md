---
layout: documentation
permalink: /docs/JiraPS/classes/AtlassianPS.JiraPS.User/
---
# AtlassianPS.JiraPS.User

## SYNOPSIS

Defines an object for Users in Jira.

## SYNTAX

```powershell
New-Object -TypeName AtlassianPS.JiraPS.User [-Property @{}]

[AtlassianPS.JiraPS.User]@{}
```

## DESCRIPTION

**fix**The `User` is an object that describes users in Jira.

## REFERENCES

The following classes use `User` for their properties:

* _TBD_

## CONSTRUCTORS

### User()

A new, empty, object of this class can be create by calling it without any
parameter.

```powershell
New-Object -TypeName AtlassianPS.JiraPS.User
[AtlassianPS.JiraPS.User]@{}
[AtlassianPS.JiraPS.User]::new()
```

### User(String)

By providing a string to the constructor, the class will try to guess for what
field the value was meant.
The value can be `accountId` , `emailAddress` or `key`.

```powershell
New-Object -TypeName AtlassianPS.JiraPS.User -ArgumentList "me@about.io"
[AtlassianPS.JiraPS.User]::new("admin")
[AtlassianPS.JiraPS.User]::new("000000:00000000-0000-0000-0000-0000000000")
```

### Hashtable

A new object of type `[AtlassianPS.JiraPS.User]` can be create by providing a
hashtable with the desired values for the properties.

```powershell
[AtlassianPS.JiraPS.User]@{
    accountId = "000000:00000000-0000-0000-0000-0000000000"
    key = "admin"
    emailAddress = "me@about.io"
}
```

## PROPERTIES

### Key

The Key is the identifier of a `User` for Jira Server.

_This value can't be changed and is assigned by the server._

**This field is only available for Jira Server instances.**
**For Jira Cloud, please use `accountId`.**

```yaml
Type: String
Required: False
Default value: None
```

### AccountId

The AccountId is the identifier of a `User` for Jira Cloud.

_This value can't be changed and is assigned by the server._

**This field is only available for Jira Cloud instances.**
**For Jira Server, please use `key`.**

```yaml
Type: String
Required: False
Default value: None
```

### Name

```yaml
Type: String
Required: False
Default value: None
```

### DisplayName

The name to be displayed.

_This value is set by the user._

**Depending on privacy settings, the module might be unable to fetch this value.**

```yaml
Type: String
Required: False
Default value: None
```

### EmailAddress

The users email address.

**Depending on privacy settings, the module might be unable to fetch this value.**

```yaml
Type: String
Required: False
Default value: None
```

### Active

A flag to identify if the account can still be accessed by the user.

```yaml
Type: Boolean
Required: True
Default value: False
```

### Avatar

The information of the users avatar images.

```yaml
Type: Avatar
Required: False
Default value: None
```

### TimeZone

The users timezone.

**Depending on privacy settings, the module might be unable to fetch this value.**

```yaml
Type: String
Required: False
Default value: False
```

### Locale

The users locale.

**Depending on privacy settings, the module might be unable to fetch this value.**

```yaml
Type: String
Required: False
Default value: False
```

### AccountType

User objects in a webhook payload have a new field: `accountType`.
This field is used to distinguish different types of users,
such as normal users, app users, and Jira Service Desk customers.

Valid values:

* `atlassian`: A regular Atlassian user account.
* `app`: A system account used for Connect applications and OAuth 2.0 to represent external systems.
* `customer`: A Jira Service Desk account representing an external service desk

```yaml
Type: AtlassianPS.JiraPS.AccountType
Required: False
Default value: None
```

### Groups

A list of the group names where this users is a member of.

```yaml
Type: String[]
Required: False
Default value: False
```

### RestUrl

The url for fetching the resource via rest.

```yaml
Type: Uri
Required: False
Default value: False
```

## METHODS

### KeyValuePair[string,string] identify()

Returns a Key-Value pair containing the information of what property
(with what value) should be used to identify this user.

#### Example

```powershell
$user.identify()
```

> ```text
> Key      Value
> -------- -------
> username jon.doe
> ```

### String ToString()

When casting an object of this class to string, it will use the first none empty
property in the following order:

1. DisplayName
2. Name
3. EmailAddress
4. Key
5. AccountId
