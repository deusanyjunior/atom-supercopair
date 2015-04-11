# SuperCopair

SuperCopair is a new way to integrate cloud computing into a collaborative live coding scenario with minimum efforts in the setup. This package, created in Coffee Script for Atom.io, is developed to interact with SuperCollider and provide opportunities for the crowd of online live coders to collaborate remotely on distributed performances. Additionally, the package provides the advantages of cloud services offered by Pusher. Users can share code and evaluate lines or selected portions of code on computers connected to the same session, either at the same place and/or remotely. The package can be used for remote performances or rehearsal purposes with just an internet connection to share code and sounds. In addition, users can take advantage of code sharing to teach SuperCollider online or fix bugs in the algorithm, illustrating the cooperative idea behind the package development.


## Description

The package was created based on two other great Atom packages: SuperCollider and AtomPair. You can see more information following the links below:

Supercollider (0.4.2): https://atom.io/packages/supercollider

AtomPair (0.1.0): https://atom.io/packages/atom-pair

SuperCopair is intended for cooperative live coding using cloud services. In this case, the sync and interaction is provided by Pusher (http://pusher.com). You will need to start a session with some friends and code together on the same file. Is it possible to evaluate code and stop music in three different ways:

- Only on your system;
- Only on your friends;
- And on all systems.

You can configure a broadcast alert on the settings, and receive an alert before each external evaluation if you don't want to accept all broadcast commands.


## Environment set-up

This set-up is necessary for everyone interested on participating in this session.

### Atom

"A hackable text editor for the 21st Century" (from Atom website)

Atom is a text editor based on web technologies. It is open source ([MIT License](http://mit-license.org/)), multi platform (L-M-W), and has packages for many languages.

Download: http://atom.io/

### SuperCollider

"SuperCollider is a programming language for real time audio synthesis and algorithmic composition" (from SuperCollider website)

SuperCollider is a programming language used by some people that like live coding. It is based on a server that synthesizes code written and evaluated by the user. You can evaluate the whole code, a selected part, or just a line using keyboard shortcuts. SuperCollider is open source ([GNU General Public License](http://www.gnu.org/licenses/gpl.html)) and multi platform (L-M-W).

Download: https://supercollider.github.io/

### SuperCopair

It is possible to install Atom packages from the main window of the program. You just need to use the shortcut Ctrl-Shift-P and write Settings View: Install Packages And Themes. After this you can search for packages, install and configure them. For this tutorial, you will need to [seek and install](http://youtu.be/NJzoBmVPeYw) this special package:

- [supercopair](http://deusanyjunior.github.io/atom-supercopair/)

You can also install the shell commands on your system, open a terminal, and use the command:

$ apm install supercopair

Now, ask your friends to do the same, and let's start a new session.


## Starting a new session

### You

First of all, you need to start a new session.

> **Your steps:**

> - Open Atom
> - Create a new “file.sc” or open an existing SuperCollider file.
> - Start a new session:
 - Shift-Ctrl-P or Shift-Command-P
 - `SuperCopair: Start new pairing session`
 - Copy the “session ID” and send to your friends
> - Open a post window:
 - Shift-Ctrl-K or Shift-Command-K
> - Boot SuperCollider and evaluate:
 - `s.boot`
 - Shift-Enter
> - Play some sound to test and evaluate:
 - `().play`
 - Shift-Enter
> - Start coding while your friends join the session..


### Your friends

Now, your friends can join your session. If you are alone in the morning and want to invite a virtual friend, you can also open a separate window using the shortcut: Ctrl-Shift-N or Command-Shift-N. Your friends will need the same environment set up to join your session, but they can use any other operational system.

> **Friends steps:**

> - Open Atom
> - Copy the “session ID” shared with you
> - Join a pairing session:
 - Shift-Ctrl-P or Shift-Command-P
 - `SuperCopair: Join pairing session`
 - Paste the “session ID” and hit Enter
> - Open a post window:
 - Shift-Ctrl-K or Shift-Command-K
> - Boot SuperCollider and evaluate:
 - `s.boot`
 - Shift-Enter
> - Play some sound to test and evaluate:
 - `().play`
 - Shift-Enter
> - Start a happy and Cooperative Live Coding!


## SuperCollider info

You can use these shortcuts to interact with SuperCollider local server:

| key              | command                                              |
| ---------------- | ---------------------------------------------------- |
| Shift-Ctrl-K  | Compile library (open window if needed)              |
| Shift-Enter      | Evaluate selection or current line                   |
| Shift-Ctrl-C  | Clear post window                                    |
| Ctrl-.        | Panic ! Stop all music                               |

You can use Command instead of Ctrl while using Mac OSx.

The server control window can be opened anytime evaluating this line:

```
Server.default.makeWindow
```

Take a look at the original package if you want to lookup classes and use a text-completion.

## Shortcuts to broadcast codes and stop

Start a new session and use these commands to broadcast codes.

| key              | command                                              |
| ---------------- | ---------------------------------------------------- |
| Shift-Ctrl-Z  | Broadcast an evaluation to everyone on the session   |
| Shift-Ctrl-X  | Broadcast an evaluation exclusively to your pairs    |
| Shift-Ctrl-T  | Broadcast STOP to everyone on the session           |
| Shift-Ctrl-Y  | Broadcast STOP exclusively to your pairs            |

You can use Command instead of Ctrl while using Mac OSx, and you can also access these commands through the main menu.


## Cloud service info

SuperCopair initiates with keys from Pusher cloud service free plan, so you can just install and run.
You need to know that the free plan has some limitations.
It supports up to 20 clients per day, and you can exchange only 100k messages per day (it includes all messages sent to/from the cloud service), and the sessions may stop after reaching this limit.

The free plan allow users to exchange messages only through the US East Coast cloud server.
You can have other limits on paid plans, although the daily quota is reset only after midnight UTC for all plans. It is important to keep these informations in mind if you face any problem
or high latency. You may want to try some paid plan if you need more clients, messages, or low latency in another country.


## Support

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deusanyjunior/atom-supercopair?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Issues and pull requests are welcome.

= )

dj
