---
layout: documentation
permalink: /docs/JiraPS/classes/AtlassianPS.JiraPS.Avatar/
---

# AtlassianPS. JiraPS. Avatar

## SYNOPSIS

Defines an object for Avatars in Jira.

## SYNTAX

``` powershell
New-Object -TypeName AtlassianPS.JiraPS.Avatar [-Property @{}]

[AtlassianPS.JiraPS.Avatar]@{}
```

## DESCRIPTION

The Avatar contains the users profile picture in multiple sizes.

## REFERENCES

The following classes use `Avatar` for their properties:

* [`AtlassianPS.JiraPS.User`](/docs/JiraPS/classes/AtlassianPS.JiraPS.User/)

## CONSTRUCTORS

### Hashtable

A new object of type `[AtlassianPS.JiraPS.Avatar]` can be create by providing a
hashtable with the desired values for the properties.

``` powershell
[AtlassianPS.JiraPS.Avatar]@{
    x16 = "https://secure.gravatar.com/avatar/..."
    x24 = "https://secure.gravatar.com/avatar/..."
    x32 = "https://secure.gravatar.com/avatar/..."
    x48 = "https://secure.gravatar.com/avatar/..."
}
```

## PROPERTIES

### x16

```yaml
Type: Uri
Required: False
Default value: None
```

### x24

```yaml
Type: Uri
Required: False
Default value: None
```

### x32

```yaml
Type: Uri
Required: False
Default value: None
```

### x48

```yaml
Type: Uri
Required: False
Default value: None
```

## METHODS

