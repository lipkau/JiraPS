using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace AtlassianPS {
    namespace JiraPS {
        public enum AccountType {
            // https://developer.atlassian.com/cloud/jira/platform/deprecation-notice-user-privacy-api-migration-guide/#webhooks
            atlassian,
            app,
            customer
        }

        public enum ActorType {
            AtlassianUserRoleActor,
            AtlassianGroupRoleActor
        }

        public enum AssigneeType {
            PROJECT_DEFAULT,
            COMPONENT_LEAD,
            PROJECT_LEAD,
            UNASSIGNED
        }

        public enum FilterShareType {
            GLOBAL,
            LOGGEDIN,
            PROJECT,
            GROUP,
            ROLE
        }

        [Serializable]
        public class Attachment {
            public String ID { get; set; }
            public String FileName { get; set; }
            public User Author { get; set; }
            public DateTime Created { get; set; }
            public Int32 Size { get; set; }
            public String MimeType { get; set; }
            public String Content { get; set; }
            public String Thumbnail { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return FileName;
            }
        }

        [Serializable]
        public class Avatar {
            public Uri x16 { get; set; }
            public Uri x24 { get; set; }
            public Uri x32 { get; set; }
            public Uri x48 { get; set; }
        }

        [Serializable]
        public class Comment {
            public Comment(String value) {
                Body = value;
            }
            public Comment() { }

            public String Id { get; set; }
            public String Body { get; set; }
            public Hashtable Visibility { get; set; }
            public User Author { get; set; }
            public User UpdateAuthor { get; set; }
            public DateTime Created { get; set; }
            public DateTime Updated { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Body;
            }
        }

        [Serializable]
        public class Component {
            public Component(String value) {
                Name = value;
            }
            public Component() { }

            public String Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public User Lead { get; set; }
            public Nullable<AssigneeType> AssigneeType { get; set; }
            public User Assignee { get; set; }
            public Nullable<AssigneeType> RealAssigneeType { get; set; }
            public User RealAssignee { get; set; }
            public Boolean IsAssigneeTypeValid { get; set; }
            public Project Project { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class Field {
            public Field(String value) {
                if (value.Contains(" "))
                    Name = value;
                else if (value.ToLower() == value) {
                    Id = value;
                    Key = value;
                }
                else if (value.ToLower().Contains("customfield_")) {
                    Id = value.ToLower();
                    Key = value.ToLower();
                }
                else
                    Name = value;
            }
            public Field() { }

            public String Id { get; set; }
            public String Key { get; set; }
            public String Name { get; set; }
            public Boolean Custom { get; set; }
            public Boolean Orderable { get; set; }
            public Boolean Navigable { get; set; }
            public Boolean Searchable { get; set; }
            public String[] ClauseNames { get; set; }
            public PSObject Schema { get; set; }

            public override string ToString() {
                return Name ?? "id: " + Id;
            }
        }

        [Serializable]
        public class Filter {
            private Boolean _favorite;

            public Filter(UInt64 value) { Id = value; }
            public Filter(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
            }
            public Filter() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public User Owner { get; set; }
            public String JQL { get; set; }
            public Boolean Favorite { get { return _favorite; } set { _favorite = value; } }
            public Boolean Favourite { get { return _favorite; } set { _favorite = value; } }
            public FilterPermission[] SharePermissions { get; set; }
            public Uri RestUrl { get; set; }
            public Uri ViewUrl { get; set; }
            public Uri SearchUrl { get; set; }

            public override string ToString() {
                return Name ?? "id: " + Id;
            }
        }

        [Serializable]
        public class FilterPermission {
            public FilterPermission() { }

            public UInt64 Id { get; set; }
            public FilterShareType Type { get; set; }
            public Group Group { get; set; }
            public Project Project { get; set; }
            public Role Role { get; set; }

            // public override string ToString() // {
            //     return Type;
            // }
        }

        [Serializable]
        public class Group {
            public Group(String value) { Name = value; }
            public Group() { }

            public String Name { get; set; }
            public UInt64 Size { get; set; }
            public User[] Member { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class Issue {
            public Issue(UInt64 value) { Id = value; }
            public Issue(String value) { Key = value; }
            public Issue() { }

            public UInt64 Id { get; set; }
            public String Key { get; set; }
            public Hashtable Fields { get; set; }
            public Transition[] Transition { get; set; }
            public String Expand { get; set; }
            public Uri HttpUrl { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                if (Fields != null && Fields.ContainsKey("Summary"))
                    return "[" + Key + "] " + Fields["Summary"];
                else
                    return "[" + Key + "]";
            }
        }

        [Serializable]
        public class IssueLink {
            public IssueLink() { }

            public UInt64 Id { get; set; }
            public IssueLinkType Type { get; set; }
            public Issue OutwardIssue { get; set; }
            public Issue InwardIssue { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return "Id: " + Id;
            }
        }

        [Serializable]
        public class IssueLinkType {
            public IssueLinkType() { }

            public String Id { get; set; }
            public String Name { get; set; }
            public String InwardText { get; set; }
            public String OutwardText { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class IssueType {
            public IssueType(UInt64 value) { Id = value; }
            public IssueType(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
             }
            public IssueType() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public Boolean Subtask { get; set; }
            public Uri IconUrl { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name ?? "id: " + Id;
            }
        }

        [Serializable]
        public class Priority {
            public Priority(UInt64 value) { Id = value; }
            public Priority(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
            }
            public Priority() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public String StatusColor { get; set; }
            public Boolean IsSubtask { get; set; }
            public Nullable<Int16> AvatarId { get; set; }
            public Nullable<Int16> EntityId  { get; set; }
            public Nullable<Int16> HierarchyLevel { get; set; }
            // TODO:  public Scope Scope { get; set; }
            public Uri IconUrl { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name ?? "id: " + Id;
            }
        }

        [Serializable]
        public class Project { public Project(UInt64 value) { Id = value; }
            public Project(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Key = value;
            }
            public Project() { }

            public UInt64 Id { get; set; }
            public String Key { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public User Lead { get; set; }
            public IssueType[] IssueTypes { get; set; }
            public Role[] Roles { get; set; }
            public ProjectCategory Category { get; set; }
            public Component[] Components { get; set; }
            public String Style { get; set; }
            public Uri HttpUrl { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                if (String.IsNullOrEmpty(Name))
                    return Name;
                else if (String.IsNullOrEmpty(Key))
                    return "key: " + Key;
                else if (String.IsNullOrEmpty(Id.ToString()))
                    return "id: " + Id;
                else
                    return "";
            }
        }

        [Serializable]
        public class ProjectCategory {
            public ProjectCategory() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class RemoteIssueLink {
            public UInt32 Id { get; set; }
            public String GlobalId { get; set; }
            public Dictionary<String, String> Application { get; set; }
            public String Relationship { get; set; }
            public RemoteObject Object { get; set; }
            public Uri RestUrl { get; set; }
        }

        [Serializable]
        public class RemoteObject {
            public Uri Url { get; set; }
            public String Title { get; set; }
            public String Summary { get; set; }
            public PSObject Icon { get; set; }
            public PSObject Status { get; set; }
        }

        [Serializable]
        public class Role {
            public Role(String value) {
                Name = value;
            }
            public Role() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public RoleActor[] Actors { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class RoleActor {
            public RoleActor() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String DisplayName { get; set; }
            public ActorType Type { get; set; }
        }

        [Serializable]
        public class Status {
            public Status(UInt64 value) { Id = value; }
            public Status(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
             }
            public Status() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public StatusCategory Category { get; set; }
            public Uri IconUrl { get; set; }
            public Uri RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class StatusCategory {
            public UInt64 Id { get; set; }
            public String Key { get; set; }
            public String Name { get; set; }
            public String ColorName { get; set; }
            public Uri RestUrl { get; set; }
        }

        [Serializable]
        public class Transition {
            public Transition(UInt64 value) { Id = value; }
            public Transition(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
             }
            public Transition() { }

            public UInt64 Id { get; set; }
            public String Name { get; set; }
            public Status ResultStatus { get; set; }

            public override string ToString() {
                return Name;
            }
        }

        [Serializable]
        public class User {
            public User(String value) {
                if (value == "Unassigned") {
                    Key = "";
                    DisplayName = "Unassigned";
                }
                else if (value == "Default") {
                    Key = "-1";
                    DisplayName = "Default Assignee";
                }
                else if (Regex.IsMatch(value, @"\d+:([\da-f]+-){4}[\da-f]+"))
                    AccountId = value;
                else if (Regex.IsMatch(value, @".+\@.+\..{2,}"))
                    EmailAddress = value;
                else
                    Key = value;
            }
            public User() { }

            public String Key { get; set; }
            public String AccountId { get; set; }
            public String Name { get; set; }
            public String DisplayName { get; set; }
            public String EmailAddress { get; set; }
            public Boolean Active { get; set; }
            public Avatar Avatar { get; set; }
            public String TimeZone { get; set; }
            public String Locale { get; set; }
            public Nullable<AccountType> AccountType { get; set; }
            public String[] Groups { get; set; }
            public Uri RestUrl { get; set; }

            public Nullable<KeyValuePair<string, string>> identify()
            {
                if (!String.IsNullOrEmpty(AccountId))
                    return new KeyValuePair<string, string>("accountId", AccountId);
                else if (!String.IsNullOrEmpty(Key))
                    return new KeyValuePair<string, string>("username", Key);
                else
                    return null;
            }

            public override string ToString() {
                return DisplayName ?? Name ?? EmailAddress ?? Key ?? AccountId;
            }
        }

        [Serializable]
        public class Version {
            public Version(UInt64 value) { Id = value; }
            public Version(String value) {
                UInt64 _id;
                if (UInt64.TryParse(value, out _id))
                    Id = _id;
                else
                    Name = value;
             }
            public Version() { }

            public UInt64 Id { get; set; }
            public UInt64 ProjectId { get; set; }
            public String Name { get; set; }
            public String Description { get; set; }
            public Boolean Archived { get; set; }
            public Boolean Released { get; set; }
            public Nullable<DateTime> StartDate { get; set; }
            public Nullable<DateTime> ReleaseDate { get; set; }
            public Boolean Overdue { get; set; }
            public String RestUrl { get; set; }

            public override string ToString() {
                return Name;
            }
        }
    }
}
