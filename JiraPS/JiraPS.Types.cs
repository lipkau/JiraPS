using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;
using System.Text.RegularExpressions;

namespace AtlassianPS
{
    namespace JiraPS
    {
        public enum AccountType
        {
            // https://developer.atlassian.com/cloud/jira/platform/deprecation-notice-user-privacy-api-migration-guide/#webhooks
            atlassian,
            app,
            customer
        }
        [Serializable]
        public class Avatar {
            public Uri x16 { get; set; }
            public Uri x24 { get; set; }
            public Uri x32 { get; set; }
            public Uri x48 { get; set; }
        }


        [Serializable]
        public class Field
        {
            public Field(String value)
            {
                if (value.Contains(" "))
                {
                    Name = value;
                }
                else if (value.ToLower() == value)
                {
                    Id = value;
                    Key = value;
                }
                else if (value.ToLower().Contains("customfield_"))
                {
                    Id = value.ToLower();
                    Key = value.ToLower();
                }
                else
                {
                    Name = value;
                }
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

                return Name ?? "id: " + Id;
            }
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

            public override string ToString()
            {
                return Name;
            }
        }

        [Serializable]
        public class StatusCategory
        {
            public UInt64 Id { get; set; }
            public String Key { get; set; }
            public String Name { get; set; }
            public String ColorName { get; set; }
            public Uri RestUrl { get; set; }
        }

        [Serializable]
        public class User
        {
            public User(String value)
            {
                if (Regex.IsMatch(value, @"\d+:([\da-f]+-){4}[\da-f]+"))
                {
                    AccountId = value;
                }
                else if (Regex.IsMatch(value, @".+\@.+\..{2,}"))
                {
                    EmailAddress = value;
                }
                else
                {
                    Key = value;
                }
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
                {
                    return new KeyValuePair<string, string>("accountId", AccountId);
                }
                else if (!String.IsNullOrEmpty(Key))
                {
                    return new KeyValuePair<string, string>("username", Key);
                }
                else
                {
                    return null;
                }
            }

            public override string ToString()
            {
                return DisplayName ?? Name ?? EmailAddress ?? Key ?? AccountId;
            }
        }

        [Serializable]
        public class Avatar
        {
            public Uri x16 { get; set; }
            public Uri x24 { get; set; }
            public Uri x32 { get; set; }
            public Uri x48 { get; set; }
        }
    }
}
