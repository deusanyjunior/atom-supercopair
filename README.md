# SupercoPair

Merge of two great Atom packages: SuperCollider and AtomPair. You can see more information following the links below:

Supercollider (0.4.2): https://atom.io/packages/supercollider

AtomPair (0.1.0): https://atom.io/packages/atom-pair

## Description

This package is intended for cooperative live coding using cloud services. In this case, the sync and interaction is provided by Pusher (http://pusher.com). You will need to start a session with some friends and code together on the same file. Is it possible to evaluate code and stop music in three different ways:

- Only on your system;
- Only on your friends;
- And on all systems.

You can configure a bypass on the settings, and receive an alert before each external evaluation if you don't want to accept all broadcast commands.

##Starting a new session

###You

First of all, you need to start a new session.

> **Your steps:**

> - Open Atom
> - Create a new “file.sc” or open an existing SuperCollider file.
> - Start a new session:
 - (Mac OSx shortcut) Command-Shift-P
 - (write) Supercopair: Start new pairing session
 - Copy the “session ID” and send to your friends
> - Open a post window:
 - (Mac OSx shortcut) Shift-Command-K
> - Boot SuperCollider and evaluate:
 - (write) s.boot
 - (Mac OSx shortcut) Shift-Enter
> - Play some sound to test and evaluate:
 - (write) ().play
 - (Mac OSx shortcut) Shift-Enter
> - Start coding while your friends join the session..


### Your friends

Now, your friends can join your session. If you are alone in the morning and want to invite a virtual friend, you can also open a separate window using the (Mac OSx) shortcut: Command-Shift-N. Your friends will need the same environment set up to join your session, but they can use any other operational system.

> **Friends steps:**

> - Open Atom
> - Copy the “session ID” shared with you
> - Join a pairing session:
 - (Mac OSx shortcut) Command-Shift-P
 - (write) Supercopair: Join pairing session
 - Paste the “session ID” and hit Enter
> - Open a post window:
 - (Mac OSx shortcut) Shift-Command-K
> - Boot SuperCollider and evaluate:
 - (write) s.boot
 - (Mac OSx shortcut) Shift-Enter
> - Play some sound to test and evaluate:
 - (write) ().play
 - (Mac OSx shortcut) Shift-Enter
> - Start a happy and Cooperative Live Coding!


## SuperCollider info

You can use these shortcuts to interact with SuperCollider local server:

| key              | command                                              |
| ---------------- | ---------------------------------------------------- |
| Shift-Command-K  | Compile library (open window if needed)              |
| Shift-Enter      | Evaluate selection or current line                   |
| Shift-Command-C  | Clear post window                                    |
| Command-.        | Panic ! Stop all music                               |

The server control window can be opened anytime evaluating this line:

```
Server.default.makeWindow
```

Take a look at the original package if you want to lookup classes and use a text-completion.


## AtomPair info

AtomPair uses Pusher cloud service free plan and has some limitations. This service supports up to 20 clients per day. You can exchange 100k messages per day (it includes all messages sent to/from the cloud service), and the sessions may stop after reaching this limit.

The free plan allow users to exchange messages only through the US East Coast cloud server.
You can have other limits on paid plans, although the daily quota is reset only after midnight UTC for all plans. It is important to keep these informations in mind if you face any problem
or high latency. You may want to try some paid plan if you need more clients, messages, or low latency in another country.


## Shortcuts to broadcast codes

Start a new session and use these commands to broadcast codes.

| key              | command                                              |
| ---------------- | ---------------------------------------------------- |
| `shift-cmd-b`    | Broadcast an evaluation to everyone on the session   |
| `shift-cmd-x`    | Broadcast an evaluation exclusively to your pairs    |
| `shift-cmd-t`    | Broadcast cmd-. to everyone on the session           |
| `shift-cmd-u`    | Broadcast cmd-. exclusively to your pairs            |

You can access these commands through the main menu.

## Support

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deusanyjunior/atom-supercopair?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Issues and pull requests are welcome.

= )

dj
